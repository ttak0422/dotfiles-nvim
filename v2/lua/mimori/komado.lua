-- Thin adapter: visibility owns subscriptions; all render providers read cache.
local client = require("mimori.client")
local M = {}
local release, group, pending, komado, cap, view, detail_view, all_view
local generation = 0
local event = "MimoriViewChanged"
local known = { running = true, idle = true, ended = true, waiting = true, unknown = true }
local function clean(value, width)
  local text = tostring(value or "?"):gsub("\27%[[0-?]*[ -/]*[@-~]", ""):gsub("\27%][^\7]*\7", "")
  text = text:gsub("[%c]", " ")
  -- Also strip Unicode line/control separators used to spoof displayed rows.
  text = text:gsub("\194[\128-\159]", " "):gsub("\226\128[\168-\174]", " "):gsub("\226\129[\166-\169]", " ")
  width = math.max(1, width or 120)
  if vim.fn.strdisplaywidth(text) <= width then return text end
  local result = ""
  for _, c in ipairs(vim.fn.split(text, "\\zs")) do
    if vim.fn.strdisplaywidth(result .. c .. "…") > width then break end
    result = result .. c
  end
  return result .. "…"
end
M.clean = clean
local function state_label(s) return known[s] and s or ("unknown (" .. clean(s, 30) .. ")") end
local function waiting(r) return r.unresolved_requests > 0 or r.attention_unknown or not r.unresolved_count_exact end
local function label(r)
  local n = tostring(r.unresolved_requests) .. (r.unresolved_count_exact and "" or "+?")
  return string.format("%s · %s · child %d · wait %s%s", r.name or r.session_id, state_label(r.aggregate_state), r.running_descendants, n,
    r.attention_unknown and " attention?" or "")
end
local function rows(snapshot, limit)
  local result = { { text = "mimori · " .. snapshot.status .. (snapshot.data and snapshot.status ~= "connected" and " (retained)" or ""), kind = "health" } }
  if snapshot.diagnostic then result[#result + 1] = { text = snapshot.diagnostic, kind = "diagnostic" } end
  if snapshot.collector_diagnostic then
    result[#result + 1] = { text = "Last collector error (" .. snapshot.collector_diagnostic.observed_at .. "): " .. snapshot.collector_diagnostic.message, kind = "diagnostic" }
  end
  if not snapshot.data then return result end
  local roots = snapshot.data.roots
  local shown = math.min(limit or #roots, #roots)
  for i = 1, shown do result[#result + 1] = { text = label(roots[i]), root = roots[i], kind = "root" } end
  if #roots == 0 then result[#result + 1] = { text = "No classified roots", kind = "empty" } end
  if shown < #roots then
    local waits = 0
    for i = shown + 1, #roots do if waiting(roots[i]) then waits = waits + 1 end end
    result[#result + 1] = { text = string.format("+%d hidden roots · %d waiting/unknown · a: all", #roots - shown, waits), kind = "more" }
  end
  local unclassified = snapshot.data.unclassified
  if #unclassified > 0 then
    result[#result + 1] = { text = string.format("Unclassified: %d · a: all", #unclassified), kind = "unclassified" }
    -- The sidebar stays capped; all view exposes every unclassified identity.
    if not limit then for _, r in ipairs(unclassified) do result[#result + 1] = { text = label(r) .. " · " .. r.classification, root = r, kind = "root" } end end
  end
  return result
end
M.rows = rows
local function changed()
  pcall(vim.api.nvim_exec_autocmds, "User", { pattern = event, modeline = false })
end
local function visible()
  if not komado then return false end
  local s = komado.get_state()
  return s and s.winid and s.bufnr and vim.api.nvim_win_is_valid(s.winid)
    and vim.api.nvim_buf_is_valid(s.bufnr) and vim.api.nvim_win_get_buf(s.winid) == s.bufnr
    and vim.api.nvim_win_get_tabpage(s.winid) == vim.api.nvim_get_current_tabpage()
end
M.visible = visible
local function write(v, text)
  if not v or not vim.api.nvim_buf_is_valid(v.buf) then return end
  vim.bo[v.buf].modifiable = true
  vim.api.nvim_buf_set_lines(v.buf, 0, -1, false, text)
  vim.bo[v.buf].modifiable = false
end
local function render_all(v, snapshot)
  local selected
  if v.rows and vim.api.nvim_win_is_valid(v.win) then
    local old = v.rows[vim.api.nvim_win_get_cursor(v.win)[1]]
    selected = old and old.root and client.identity(old.root)
  end
  v.rows = rows(snapshot)
  local lines, line = {}, nil
  for i, row in ipairs(v.rows) do
    lines[i] = clean(row.text, vim.api.nvim_win_get_width(v.win) - 2)
    if selected and row.root and client.identity(row.root) == selected then line = i end
  end
  write(v, lines)
  if line then pcall(vim.api.nvim_win_set_cursor, v.win, { line, 0 }) end
end
local function dispose(v)
  if not v or v.closed then return end
  v.closed = true
  if v.release then v.release(); v.release = nil end
  if v.cancel then v.cancel() end
  if v.group then pcall(vim.api.nvim_del_augroup_by_id, v.group) end
  if vim.api.nvim_buf_is_valid(v.buf) then pcall(vim.api.nvim_buf_delete, v.buf, { force = true }) end
end
local function subscribe_view(v)
  if v.closed or not v.callback then return end
  local shown = vim.api.nvim_win_is_valid(v.win) and vim.api.nvim_buf_is_valid(v.buf)
    and vim.api.nvim_win_get_buf(v.win) == v.buf
    and vim.api.nvim_win_get_tabpage(v.win) == vim.api.nvim_get_current_tabpage()
  if shown and not v.release then
    if v.resume then v.resume() end
    v.release = client.subscribe(v.callback)
  elseif not shown and v.release then
    v.release(); v.release = nil
    if v.cancel then v.cancel(); v.cancel = nil end
  end
end
local function open_view(name)
  vim.cmd("botright vsplit")
  local v = { win = vim.api.nvim_get_current_win(), buf = vim.api.nvim_create_buf(false, true) }
  vim.api.nvim_win_set_buf(v.win, v.buf)
  vim.api.nvim_buf_set_name(v.buf, "mimori://" .. name)
  vim.bo[v.buf].buftype = "nofile"; vim.bo[v.buf].bufhidden = "wipe"; vim.bo[v.buf].swapfile = false
  vim.bo[v.buf].filetype = "mimori"; vim.wo[v.win].wrap = false
  v.group = vim.api.nvim_create_augroup("MimoriView" .. v.buf, { clear = true })
  vim.api.nvim_create_autocmd({ "WinClosed", "BufWipeout", "TabEnter", "TabLeave", "BufWinEnter", "BufWinLeave" }, {
    group = v.group, callback = function()
      vim.schedule(function()
        if v.closed then return end
        if not vim.api.nvim_win_is_valid(v.win) or not vim.api.nvim_buf_is_valid(v.buf)
          or vim.api.nvim_win_get_buf(v.win) ~= v.buf then dispose(v) else subscribe_view(v) end
      end)
    end,
  })
  vim.keymap.set("n", "q", function() dispose(v) end, { buffer = v.buf })
  vim.keymap.set("n", "r", client.refresh, { buffer = v.buf })
  return v
end
function M.open_detail(root)
  dispose(detail_view)
  local v = open_view("detail"); detail_view = v
  local key = client.identity(root)
  local function fetch()
    if v.cancel then v.cancel() end
    v.cancel = client.detail(root.provider, root.session_id, function(row, err)
      if v.closed then return end
      if not row then write(v, { clean(err), "r: refresh · q: close" }); return end
      local lines = { "mimori detail", label(row) }
      for _, k in ipairs({ "provider", "session_id", "generation", "cwd", "state", "aggregate_state", "relation", "parent_id", "root_id", "classification", "liveness", "ordering", "last_event_at" }) do
        lines[#lines + 1] = k .. ": " .. tostring(row[k] or "—")
      end
      lines[#lines + 1] = "Own unresolved request IDs:"
      for _, id in ipairs(row.request_ids == vim.NIL and {} or row.request_ids) do lines[#lines + 1] = "  " .. id end
      lines[#lines + 1] = "Counts are backend aggregates; liveness unknown is not idle."
      for i, line in ipairs(lines) do lines[i] = clean(line, vim.api.nvim_win_get_width(v.win) - 2) end
      write(v, lines)
    end)
  end
  local last
  v.resume = function() last = nil end
  v.callback = function(snapshot)
    if v.closed or not snapshot.data then return end
    local found
    for _, set in ipairs({ snapshot.data.roots, snapshot.data.unclassified }) do
      for _, row in ipairs(set) do if client.identity(row) == key then found = row end end
    end
    if last ~= snapshot.data then last = snapshot.data; fetch() end
    if not found then write(v, { "NotFound", "r: refresh · q: close" }) end
  end
  subscribe_view(v)
  vim.keymap.set("n", "r", function() client.refresh(); fetch() end, { buffer = v.buf })
  if not last then write(v, { "Loading…" }) end
end
function M.open_all()
  dispose(all_view)
  local v = open_view("all"); all_view = v
  v.callback = function(snapshot) if not v.closed then render_all(v, snapshot) end end
  subscribe_view(v)
  vim.keymap.set("n", "<CR>", function()
    local row = v.rows[vim.api.nvim_win_get_cursor(v.win)[1]]
    if row and row.root then M.open_detail(row.root) end
  end, { buffer = v.buf })
end
local function check()
  pending = false
  if visible() and not release then
    release = client.subscribe(function(snapshot) view = snapshot; changed() end)
  elseif not visible() and release then release(); release = nil; view = client.snapshot() end
end
local function recheck()
  if pending then return end
  pending = true
  local epoch = generation
  vim.schedule(function() if epoch == generation then check() end end)
end
function M.shutdown()
  generation = generation + 1; pending = false
  if release then release(); release = nil end
  dispose(all_view); dispose(detail_view); all_view = nil; detail_view = nil
  if group then pcall(vim.api.nvim_del_augroup_by_id, group); group = nil end
end
function M.setup(opts)
  M.shutdown()
  opts = opts or {}; cap = opts.cap or 10
  assert(cap > 0 and cap == math.floor(cap), "cap must be a positive integer")
  komado = require("komado"); view = client.snapshot()
  group = vim.api.nvim_create_augroup("MimoriKomado", { clear = true })
  vim.api.nvim_create_autocmd("User", { group = group, pattern = { "KomadoWindowAfterOpen", "KomadoWindowAfterClose" }, callback = recheck })
  vim.api.nvim_create_autocmd({ "TabEnter", "TabLeave", "WinEnter", "WinClosed", "BufWinEnter", "BufWinLeave", "BufWipeout" }, { group = group, callback = recheck })
  vim.api.nvim_create_autocmd("VimLeavePre", { group = group, callback = M.shutdown })
  vim.api.nvim_create_user_command("MimoriAll", M.open_all, {})
  vim.api.nvim_create_user_command("MimoriRefresh", client.refresh, {})
  recheck()
  local utils, Line = require("komado.utils"), require("komado.dsl").Line
  return {
    update = { "User", pattern = event },
    utils.mapped_list(function() return rows(view, cap) end, function(item)
      return Line({
        mappings = {
          a = M.open_all,
          r = client.refresh,
          ["<CR>"] = function(_, ctx)
            local row = ctx.ctx.item
            if row.root then M.open_detail(row.root) else M.open_all() end
          end,
        },
        provider = function(self)
          local s = self._sidebar and self._sidebar._state
          return clean(item.text, s and s._content_width or 36)
        end,
        hl = item.kind == "diagnostic" and "WarningMsg" or nil,
      })
    end),
  }
end
return M
