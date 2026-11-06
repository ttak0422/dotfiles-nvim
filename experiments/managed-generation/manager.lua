-- Isolated, cooperative generation protocol. Not a general plugin unloader.
local api = vim.api
local uv = vim.uv or vim.loop
local M = {}
local serial = 0

local function plain(value, seen)
  local kind = type(value)
  if kind == "string" or kind == "boolean" or kind == "nil" then return value end
  if kind == "number" then assert(value == value and math.abs(value) < math.huge, "finite numbers only"); return value end
  assert(kind == "table" and getmetatable(value) == nil, "state must be plain data")
  seen = seen or {}
  assert(not seen[value], "cyclic state")
  seen[value] = true
  local result = {}
  for key, item in pairs(value) do
    assert(type(key) == "string" or type(key) == "number", "plain state keys only")
    if type(key) == "number" then assert(math.abs(key) < math.huge, "finite state keys only") end
    result[key] = plain(item, seen)
  end
  seen[value] = nil
  return result
end

function M.new(opts)
  opts = opts or {}
  serial = serial + 1
  local command = opts.command or "PocGeneration"
  assert(api.nvim_get_commands({ builtin = false })[command] == nil, "command collision")
  local self = { current = nil, epoch = 0, next_id = 0, phase = "idle", errors = {},
    command = command, interval = opts.interval or 10000, closed = false }
  self.group = api.nvim_create_augroup("ManagedGenerationPoc" .. serial, { clear = true })

  local function diagnostic(stage, message)
    self.errors[#self.errors + 1] = { stage = stage, error = tostring(message) }
  end
  local function valid(ctx, epoch)
    return not self.closed and self.phase == "active" and ctx.alive
      and self.current == ctx and self.epoch == epoch
  end
  local function dispose(ctx)
    if not ctx or not ctx.alive then return true end
    ctx.alive = false
    local ok = true
    for i = #ctx.owned, 1, -1 do
      local succeeded, err = pcall(ctx.owned[i])
      if not succeeded then diagnostic("dispose", err); ok = false end
    end
    ctx.owned = {}
    return ok
  end
  local function context(definition)
    self.next_id = self.next_id + 1
    local ctx = { id = self.next_id, definition = definition, alive = true, owned = {} }
    function ctx:own(fn)
      assert(self.alive and type(fn) == "function", "invalid resource acquisition")
      self.owned[#self.owned + 1] = fn
    end
    function ctx:guard(fn)
      local epoch = self.manager.epoch
      return function(...)
        local args = { n = select("#", ...), ... }
        vim.schedule(function()
          if not valid(self, epoch) then return end
          local ok, err = pcall(fn, unpack(args, 1, args.n))
          if not ok then diagnostic("callback", err) end
        end)
      end
    end
    function ctx:autocmd(pattern, callback)
      assert(self.alive and type(callback) == "function", "invalid autocmd acquisition")
      local id = api.nvim_create_autocmd("User", { group = self.manager.group, pattern = pattern,
        callback = function(event)
          if valid(self, self.gate_epoch) then
            local ok, err = pcall(callback, event)
            if not ok then diagnostic("autocmd", err) end
          end
        end })
      self:own(function() api.nvim_del_autocmd(id) end)
    end
    ctx.manager = self
    return ctx
  end
  local function resume()
    self.phase = self.current and "active" or "idle"
    self.timer:start(self.interval, self.interval, function() self:queue("on_timer") end)
  end
  local function blocked(stage, message)
    self.phase = "restartRequired"
    self.epoch = self.epoch + 1
    self.timer:stop()
    diagnostic(stage, message)
    return { status = "restartRequired", stage = stage, error = tostring(message) }
  end

  function self:snapshot()
    assert(self.current, "no active generation")
    return { version = self.current.definition.stateVersion, data = plain(self.current.service.state) }
  end
  function self:call(method, ...)
    assert(self.phase == "active" and not self.closed, self.phase)
    local service = self.current.service
    return assert(service[method], "unknown method " .. method)(...)
  end
  function self:queue(method, ...)
    if not self.current or self.phase ~= "active" or self.closed then return end
    local ctx, epoch, args = self.current, self.epoch, { n = select("#", ...), ... }
    vim.schedule(function()
      if valid(ctx, epoch) and ctx.service[method] then
        local ok, err = pcall(ctx.service[method], unpack(args, 1, args.n))
        if not ok then diagnostic("dispatch", err) end
      end
    end)
  end
  function self:swap(definition)
    assert(not self.closed and self.phase ~= "restartRequired", self.phase)
    assert(self.phase == "active" or self.phase == "idle", "transition already in progress")
    -- Validate descriptors without invoking candidate code in the active editor.
    local ok, err = pcall(function()
      assert(type(definition) == "table" and type(definition.activate) == "function", "invalid candidate")
      assert(type(definition.stateVersion) == "number" and definition.stateVersion >= 1
        and definition.stateVersion % 1 == 0, "invalid state version")
      assert(type(definition.initial) == "table", "plain initial state required")
      plain(definition.initial)
    end)
    if not ok then return { status = "rejected", stage = "validate", error = tostring(err) } end
    local previous = self.current
    self.timer:stop()
    self.phase = "quiescing"
    self.epoch = self.epoch + 1 -- Invalidates old async/queued work even if the candidate fails.
    local candidate = context(definition)
    ok, err = pcall(function()
      local state = plain(definition.initial)
      if previous then
        local snapshot = self:snapshot()
        if snapshot.version == definition.stateVersion then state = snapshot.data
        else
          assert(type(definition.migrate) == "function", "migration required")
          state = plain(definition.migrate(snapshot))
        end
      end
      candidate.service = definition.activate(candidate, state)
      assert(type(candidate.service) == "table" and type(candidate.service.run) == "function", "invalid service")
      assert(type(candidate.service.state) == "table", "plain service state required")
      plain(candidate.service.state)
    end)
    if not ok then
      if not dispose(candidate) then return blocked("candidate-cleanup", err) end
      -- Existing registrations capture a separate gate epoch; refresh that epoch on resume.
      if previous then previous.gate_epoch = self.epoch end
      resume()
      return { status = previous and "retainedPrevious" or "rejected", stage = "activate", error = tostring(err) }
    end
    self.current = candidate -- Single non-yielding publish point for the managed facade.
    candidate.gate_epoch = self.epoch
    if previous and not dispose(previous) then return blocked("retire", "previous cleanup failed") end
    resume()
    return { status = "committed", generation = candidate.id }
  end

  self.facade = {
    run = function(...) return self:call("run", ...) end,
    read = function(...) return self:call("read", ...) end,
  }
  self.timer = assert(uv.new_timer())
  api.nvim_create_user_command(command, function(ev) self.facade.run(unpack(ev.fargs)) end, { nargs = "*" })
  api.nvim_create_autocmd("User", { group = self.group, pattern = opts.event or "PocGenerationEvent",
    callback = function() self:queue("on_event") end })

  function self:close()
    if self.closed then return end
    self.closed = true
    self.phase = "closed"
    self.epoch = self.epoch + 1
    self.timer:stop()
    self.timer:close()
    api.nvim_del_user_command(self.command)
    local ok = dispose(self.current)
    api.nvim_del_augroup_by_id(self.group)
    return ok
  end
  return self
end

return M
