-- Small experimental runtime. No fetching, package updates or hot reload.
local M = {}
local api = vim.api

function M.new(plan, root)
  local self = { features = {}, order = {}, contexts = {}, trace = {}, errors = {}, requests = {} }
  local next_generation = 0
  local group = api.nvim_create_augroup("PureNixPoc", { clear = true })
  local command_proxies = {}

  local function error_at(id, phase, err)
    self.errors[#self.errors + 1] = { id = id, phase = phase, error = tostring(err) }
  end

  local function guarded(ctx, phase, fn, ...)
    local args = { ... }
    local ok, value = xpcall(function() return fn(unpack(args)) end, debug.traceback)
    if not ok then error_at(ctx.id, phase, value) end
    return ok, value
  end

  local function context(feature, buf)
    next_generation = next_generation + 1
    local ctx = { id = feature.id, bufnr = buf, runtime = self, state = {}, options = feature.options,
      alive = true, generation = next_generation, owned = {}, pending = {}, sequence = 0 }

    function ctx:own(fn)
      assert(self.alive, "cannot acquire resources after disposal")
      local entry = { fn = fn }
      self.owned[#self.owned + 1] = entry
      -- Forget completed work, or release a resource once. Keep no dead ledger entries.
      return function(run)
        if not entry.fn then return end
        local cleanup = entry.fn
        entry.fn = nil
        for i, candidate in ipairs(self.owned) do
          if candidate == entry then table.remove(self.owned, i); break end
        end
        if run then guarded(self, "cleanup", cleanup) end
      end
    end

    function ctx:latest(key, begin, apply)
      if not self.alive then return end
      assert(self.bufnr, "latest requires a buffer scope")
      local previous = self.pending[key]
      if previous then
        previous.active = false
        if previous.release then previous.release(true) end
      end
      self.sequence = self.sequence + 1
      local request = { active = true, sequence = self.sequence, generation = self.generation,
        tick = api.nvim_buf_get_changedtick(self.bufnr) }
      self.pending[key] = request
      local ok, cancel = guarded(self, "begin", begin, function(value)
        if request.queued then return end
        request.queued = true
        vim.schedule(function()
          if request.release then request.release(false) end
          local current = self.alive and request.active and self.pending[key] == request
            and request.generation == self.generation and api.nvim_buf_is_valid(self.bufnr)
            and api.nvim_buf_is_loaded(self.bufnr)
            and request.tick == api.nvim_buf_get_changedtick(self.bufnr)
          if self.pending[key] == request then self.pending[key] = nil end
          request.active = false
          if current then guarded(self, "apply", apply, value) end
        end)
      end)
      if not ok then
        request.active = false
        self.pending[key] = nil
      elseif type(cancel) ~= "function" then
        request.active = false
        self.pending[key] = nil
        error_at(self.id, "begin", "provider must return a cancellation function")
      else
        request.release = self:own(cancel)
      end
    end

    return ctx
  end

  local function dispose(ctx)
    if not ctx or not ctx.alive then return end
    ctx.alive = false -- Invalidate before any cancellation can call back.
    next_generation = next_generation + 1
    ctx.generation = next_generation
    for _, request in pairs(ctx.pending) do request.active = false end
    while #ctx.owned > 0 do
      local entry = table.remove(ctx.owned)
      local fn = entry.fn
      entry.fn = nil
      if fn then guarded(ctx, "cleanup", fn) end
    end
    ctx.pending = {}
  end

  local function hook(feature, name, ctx)
    local fn = feature.hooks[name]
    if fn == nil then return true end
    if type(fn) ~= "function" then error_at(feature.id, name, "hook must be a function"); return false end
    return guarded(ctx, name, fn, ctx)
  end

  for _, spec in ipairs(plan.features) do
    local feature = vim.deepcopy(spec)
    feature.status = "registered"
    -- Loading hook definitions must have no side effects. Only the explicit hooks execute.
    local ok, hooks = pcall(function() return assert(loadfile(root .. "/" .. spec.hooks))() end)
    feature.hooks = ok and type(hooks) == "table" and hooks or {}
    feature.definition_ok = ok and type(hooks) == "table"
    if not feature.definition_ok then error_at(feature.id, "definition", hooks) end
    feature.session = context(feature)
    self.features[feature.id] = feature
    self.order[#self.order + 1] = feature
    self.contexts[feature.id] = {}
  end

  function self:ensure(id)
    local f = assert(self.features[id], "unknown feature " .. id)
    if f.status == "ready" then return true end
    if f.status ~= "registered" or not f.definition_ok then return false end
    f.status = "loading"
    for _, dependency in ipairs(f.requires) do
      if not self:ensure(dependency) then
        f.status = "blocked"
        error_at(id, "dependency", dependency .. " is not ready")
        return false
      end
    end
    -- All activation paths, including requires, release the proxy before plugin
    -- code can register the real command. close() only owns pending proxies.
    if f.activation.kind == "command" and command_proxies[f.activation.command] then
      api.nvim_del_user_command(f.activation.command)
      command_proxies[f.activation.command] = nil
    end
    local ok = hook(f, "prepare", f.session)
    if ok and f.package ~= vim.NIL and f.package ~= nil then
      ok = guarded(f.session, "load", function()
        vim.cmd.packadd(f.package)
      end)
    end
    if ok then ok = hook(f, "setup", f.session) end
    f.status = ok and "ready" or "failed"
    if not ok then dispose(f.session) end
    return ok
  end

  local function eligible(f, buf)
    return api.nvim_buf_is_valid(buf) and api.nvim_buf_is_loaded(buf)
      and vim.tbl_contains(f.activation.filetypes or {}, vim.bo[buf].filetype)
  end

  function self:attach(id, buf)
    local f = self.features[id]
    if f.scope ~= "buffer" or not eligible(f, buf) or not self:ensure(id) then return nil end
    if self.contexts[id][buf] then return self.contexts[id][buf] end
    local ctx = context(f, buf)
    self.contexts[id][buf] = ctx
    if not hook(f, "attach", ctx) then
      dispose(ctx); self.contexts[id][buf] = nil; return nil
    end
    if f.updates.initial then hook(f, "update", ctx) end
    return ctx
  end

  function self:detach(id, buf)
    dispose(self.contexts[id][buf])
    self.contexts[id][buf] = nil
  end

  for _, f in ipairs(self.order) do
    if f.activation.kind == "command" then
      local name = f.activation.command
      assert(api.nvim_get_commands({ builtin = false })[name] == nil, "command collision: " .. name)
      command_proxies[name] = true
      api.nvim_create_user_command(name, function(command)
        if not self:ensure(f.id) then error("could not load " .. f.id) end
        assert(api.nvim_get_commands({ builtin = false })[name], "plugin did not register " .. name)
        local call = { cmd = name, args = command.fargs, bang = command.bang, mods = command.smods }
        if command.range > 0 then
          call.range = command.range == 1 and { command.line1 } or { command.line1, command.line2 }
        end
        api.nvim_cmd(call, {})
      end, { nargs = "*", bang = true, range = true })
    end
    if f.scope == "buffer" then
      api.nvim_create_autocmd("FileType", { group = group, callback = function(event)
        if self.contexts[f.id][event.buf] and not eligible(f, event.buf) then self:detach(f.id, event.buf) end
        self:attach(f.id, event.buf)
      end })
      for _, event in ipairs(f.updates.events) do
        api.nvim_create_autocmd(event, { group = group, callback = function(ev)
          local ctx = self.contexts[f.id][ev.buf]
          if ctx then hook(f, "update", ctx) end
        end })
      end
      api.nvim_create_autocmd({ "BufUnload", "BufWipeout", "BufFilePre" }, {
        group = group, callback = function(ev) self:detach(f.id, ev.buf) end,
      })
      api.nvim_create_autocmd({ "BufEnter", "BufFilePost" }, {
        group = group, callback = function(ev) self:attach(f.id, ev.buf) end,
      })
    end
  end

  for _, f in ipairs(self.order) do
    if f.activation.kind == "startup" then self:ensure(f.id) end
    if f.scope == "buffer" then
      for _, buf in ipairs(api.nvim_list_bufs()) do self:attach(f.id, buf) end
    end
  end

  function self:close()
    api.nvim_del_augroup_by_id(group)
    for name in pairs(command_proxies) do pcall(api.nvim_del_user_command, name) end
    for i = #self.order, 1, -1 do
      local f = self.order[i]
      for buf in pairs(self.contexts[f.id]) do self:detach(f.id, buf) end
      dispose(f.session)
    end
    -- Third-party commands/packages intentionally remain. Restart before another generation.
  end

  return self
end

return M
