-- Generic, read-only view client. No Komado dependency or daemon ownership.
local M = {}
local current
local queue, running = {}, nil
local request
local defaults = {
  binary = "mimori", interval = 2000, timeout = 1000, ensure_timeout = 6000,
  max_backoff = 30000, max_stdout = 4 * 1024 * 1024, max_stderr = 16384,
}
local function close(timer)
  if timer and not timer:is_closing() then timer:stop(); timer:close() end
end
local function identity(row) return row.provider .. "\0" .. row.session_id end
M.identity = identity

-- JSON's uint64 generation can exceed Lua's exact integer range. Preserve large
-- integer tokens before decoding, without rewriting characters inside strings.
local function decode(text)
  local out, i = {}, 1
  while i <= #text do
    local c = text:sub(i, i)
    if c == '"' then
      local j = i + 1
      while j <= #text do
        local q = text:sub(j, j)
        if q == "\\" then j = j + 2
        elseif q == '"' then j = j + 1; break
        else j = j + 1 end
      end
      out[#out + 1] = text:sub(i, j - 1); i = j
    elseif c:match("[%d%-]") then
      local token = text:sub(i):match("^[-%d%.eE+]+")
      out[#out + 1] = token:match("^%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d+$") and ('"' .. token .. '"') or token
      i = i + #token
    else out[#out + 1] = c; i = i + 1 end
  end
  return vim.json.decode(table.concat(out))
end
local function nonempty(v) return type(v) == "string" and v ~= "" and not v:find("\0", 1, true) end
local function integer(v) return type(v) == "number" and v >= 0 and v < 9007199254740992 and v == math.floor(v) end
local function session(row)
  assert(type(row) == "table", "session is not an object")
  assert(nonempty(row.provider) and nonempty(row.session_id), "session identity missing")
  local g = row.generation
  assert((integer(g) and g > 0) or (type(g) == "string" and g:match("^[1-9]%d*$")), "invalid generation")
  row.generation = type(g) == "number" and string.format("%.0f", g) or g
  for _, k in ipairs({ "state", "aggregate_state", "relation", "classification", "ordering", "liveness", "last_event_at" }) do
    assert(nonempty(row[k]), "missing " .. k)
  end
  for _, k in ipairs({ "running_descendants", "unresolved_requests" }) do assert(integer(row[k]), "invalid " .. k) end
  assert(type(row.attention_unknown) == "boolean" and type(row.unresolved_count_exact) == "boolean", "missing attention quality")
  for _, k in ipairs({ "cwd", "name", "parent_id", "root_id" }) do
    assert(row[k] == nil or type(row[k]) == "string", "invalid " .. k)
  end
  assert(row.request_ids == vim.NIL or (type(row.request_ids) == "table" and vim.islist(row.request_ids)), "invalid request_ids")
  for _, id in ipairs(row.request_ids == vim.NIL and {} or row.request_ids) do assert(nonempty(id), "invalid request ID") end
  return row
end
local function parse(text, detail)
  local ok, result = pcall(function()
    local r = decode(text)
    assert(type(r) == "table" and r.version == 1, "incompatible API version")
    assert(nonempty(r.revision), "missing revision")
    if r.error_code or r.error then return r end
    if r.unchanged == true then return r end
    assert(r.complete == true, "incomplete response")
    if detail then r.session = session(r.session)
    else
      local seen = {}
      for _, k in ipairs({ "roots", "unclassified" }) do
        r[k] = r[k] or {}
        assert(type(r[k]) == "table" and vim.islist(r[k]), "invalid " .. k)
        for _, row in ipairs(r[k]) do
          session(row)
          assert(not seen[identity(row)], "duplicate session identity")
          seen[identity(row)] = true
        end
      end
    end
    return r
  end)
  if not ok then return nil, "contract: " .. tostring(result) end
  return result
end
local function emit(s)
  if current ~= s or s.closed then return end
  for id, cb in pairs(s.subscribers) do
    if s.subscribers[id] == cb then pcall(cb, s.view) end
  end
end
local function health(s, status, diagnostic)
  if s.view.status ~= status or s.view.diagnostic ~= diagnostic then
    s.view = vim.tbl_extend("force", s.view, { status = status })
    s.view.diagnostic = diagnostic
    emit(s)
  end
end
local function argv(s, verb)
  local a = { s.opts.binary, verb }
  if s.opts.state_dir then vim.list_extend(a, { "--state-dir", s.opts.state_dir }) end
  return a
end
-- Each process has bounded streaming buffers. Kill only the short-lived CLI,
-- never the independently detached service that `ensure` may have started.
local function run(s, args, timeout, done)
  local job = { cancelled = false, output = {}, errors = {}, bytes = 0, errbytes = 0 }
  function job.cancel()
    if job.cancelled then return end
    job.cancelled = true
    for i = #queue, 1, -1 do if queue[i] == job then table.remove(queue, i) end end
    if job.process then pcall(job.process.kill, job.process, 9) end
  end
  local function stream(field, size, limit)
    return function(err, data)
      if job.cancelled then return end
      if err then job.failure = tostring(err) end
      if data then
        job[size] = job[size] + #data
        if job[size] > limit then
          job.failure = "output limit exceeded"
          if job.process then pcall(job.process.kill, job.process, 9) end
        elseif not job.failure then job[field][#job[field] + 1] = data end
      end
    end
  end
  function job.start()
  local ok, proc = pcall(vim.system, args, {
    timeout = timeout,
    stdout = stream("output", "bytes", s.opts.max_stdout),
    stderr = stream("errors", "errbytes", s.opts.max_stderr),
  }, function(result)
    vim.schedule(function()
      running = nil
      if job.cancelled or s.closed or current ~= s then M._pump(); return end
      local err = job.failure
      if not err and result.code ~= 0 then
        err = result.code == 124 and "query timeout" or ("CLI exit " .. result.code .. ": " .. table.concat(job.errors))
      end
      done(err, table.concat(job.output))
      M._pump()
    end)
  end)
  if ok then job.process = proc
  else vim.schedule(function()
    running = nil
    if not job.cancelled and not s.closed and current == s then done("missing binary or spawn failure: " .. tostring(proc)) end
    M._pump()
  end) end
  end
  queue[#queue + 1] = job
  M._pump()
  return job
end
function M._pump()
  if running then return end
  while #queue > 0 do
    local job = table.remove(queue, 1)
    if not job.cancelled then running = job; job.start(); return end
  end
end
local function active(s) return next(s.subscribers) ~= nil end
local function schedule(s, delay)
  close(s.timer); s.timer = nil
  if not active(s) or s.closed then return end
  s.timer = vim.uv.new_timer()
  s.timer:start(delay, 0, vim.schedule_wrap(function()
    close(s.timer); s.timer = nil
    if current == s and not s.closed and active(s) then request(s) end
  end))
end
local function finish(s, err)
  s.job = nil; s.busy = false
  if err then
    s.failures = s.failures + 1
    s.ready = false
    local state = err:find("contract:", 1, true) and "incompatible" or (err:find("missing binary", 1, true) and "missing_binary" or "error")
    health(s, state, err)
  else
    s.failures = 0
    health(s, "connected")
  end
  local delay = s.failures > 0 and math.min(s.opts.max_backoff, s.opts.interval * 2 ^ math.min(s.failures - 1, 10)) or s.opts.interval
  s.retry_at = s.failures > 0 and (vim.uv.now() + delay) or 0
  local pending = s.pending; s.pending = false
  if pending and not err and active(s) then request(s) else schedule(s, delay) end
end
local function query(s, force, retried)
  local args = argv(s, "query")
  if s.opts.provider then vim.list_extend(args, { "--provider", s.opts.provider }) end
  local validator = not force and s.revision or nil
  if validator then vim.list_extend(args, { "--revision", validator }) end
  s.job = run(s, args, s.opts.timeout, function(err, text)
    if err then finish(s, err); return end
    local r, parse_err = parse(text)
    if not r then finish(s, parse_err); return end
    if r.error_code or r.error then finish(s, "contract: " .. tostring(r.error_code or r.error)); return end
    local diagnostic = r.latest_collector_diagnostic
    if diagnostic ~= nil and (type(diagnostic) ~= "table" or type(diagnostic.message) ~= "string" or type(diagnostic.observed_at) ~= "string") then
      finish(s, "contract: invalid collector diagnostic"); return
    end
    if not vim.deep_equal(s.view.collector_diagnostic, diagnostic) then
      s.view = vim.tbl_extend("force", s.view, {})
      s.view.collector_diagnostic = diagnostic; emit(s)
    end
    if r.unchanged then
      if not validator or not s.view.data or r.revision ~= validator then
        if not retried then query(s, true, true) else finish(s, "contract: unchanged without matching snapshot") end
        return
      end
    else
      local data = { roots = r.roots, unclassified = r.unclassified }
      s.revision = r.revision
      if not vim.deep_equal(s.view.data, data) then
        s.view = vim.tbl_extend("force", s.view, { data = data })
        emit(s)
      end
    end
    finish(s)
  end)
end
request = function(s, manual)
  if s.closed then return end
  if s.busy then s.pending = true; return end
  if not manual and vim.uv.now() < s.retry_at then schedule(s, s.retry_at - vim.uv.now()); return end
  close(s.timer); s.timer = nil
  s.busy = true
  if not s.view.data then health(s, "loading") end
  if s.ready then query(s); return end
  local args = argv(s, "ensure")
  vim.list_extend(args, { "--timeout", tostring(math.max(1, (s.opts.ensure_timeout - 1000) / 1000)) .. "s" })
  s.job = run(s, args, s.opts.ensure_timeout, function(err, text)
    if err then finish(s, err); return end
    local ok, result = pcall(vim.json.decode, text)
    if not ok or type(result) ~= "table" or result.version ~= 1 or result.ready ~= true then
      finish(s, "contract: invalid ensure response"); return
    end
    s.ready = true; query(s)
  end)
end
function M.shutdown()
  local s = current
  if not s or s.closed then return end
  s.closed = true; s.subscribers = {}; close(s.timer)
  if s.job then s.job.cancel() end
  if s.detail then s.detail.cancel() end
  if s.group then pcall(vim.api.nvim_del_augroup_by_id, s.group) end
end
function M.setup(opts)
  M.shutdown()
  opts = vim.tbl_extend("force", defaults, opts or {})
  assert(nonempty(opts.binary), "binary must be an executable path/name")
  assert(not opts.state_dir or opts.state_dir:sub(1, 1) == "/", "state_dir must be absolute")
  for _, k in ipairs({ "interval", "timeout", "ensure_timeout", "max_backoff", "max_stdout", "max_stderr" }) do
    assert(integer(opts[k]) and opts[k] > 0, k .. " must be a positive integer")
  end
  local s = { opts = opts, subscribers = {}, view = { status = "paused" }, retry_at = 0, failures = 0 }
  current = s
  s.group = vim.api.nvim_create_augroup("MimoriClient", { clear = true })
  vim.api.nvim_create_autocmd("VimLeavePre", { group = s.group, callback = M.shutdown })
  vim.api.nvim_create_autocmd("FocusGained", { group = s.group, callback = function() if active(s) then request(s) end end })
end
local function state() if not current or current.closed then M.setup() end; return current end
function M.snapshot() return current and current.view or { status = "paused" } end -- Read-only cached value; callers must not mutate it.
function M.refresh() request(state(), true) end
function M.subscribe(callback)
  local s, id = state(), {}
  s.subscribers[id] = callback
  pcall(callback, s.view)
  if not s.busy then request(s) end
  local released = false
  return function()
    if released then return end
    released = true; s.subscribers[id] = nil
    if not active(s) and not s.closed then
      close(s.timer); s.timer = nil
      if s.job then s.job.cancel(); s.job = nil end
      s.busy = false; s.pending = false
      health(s, "paused")
    end
  end
end
function M.detail(provider, id, callback)
  assert(nonempty(provider) and nonempty(id), "provider and session ID required")
  local s = state()
  local key = provider .. "\0" .. id
  local entry = s.detail
  local token = {}
  if not entry or entry.key ~= key then
    if entry then entry.cancel() end
    entry = { key = key, callbacks = {} }
    s.detail = entry
    local args = argv(s, "query")
    vim.list_extend(args, { "--provider", provider, "--session", id })
    local job = run(s, args, s.opts.timeout, function(err, text)
      if s.detail == entry then s.detail = nil end
      local row
      if not err then
        local r, failure = parse(text, true)
        if not r then err = failure
        elseif r.error_code or r.error then err = r.error_code == "not_found" and "NotFound" or tostring(r.error_code or r.error)
        elseif r.unchanged then err = "contract: unexpected unchanged detail"
        elseif r.session.provider ~= provider or r.session.session_id ~= id then err = "contract: detail identity mismatch"
        else row = r.session end
      end
      for _, cb in pairs(entry.callbacks) do pcall(cb, row, err) end
    end)
    entry.cancel = function() entry.callbacks = {}; job.cancel() end
  end
  entry.callbacks[token] = callback
  return function()
    entry.callbacks[token] = nil
    if not next(entry.callbacks) then
      entry.cancel()
      if s.detail == entry then s.detail = nil end
    end
  end
end
return M
