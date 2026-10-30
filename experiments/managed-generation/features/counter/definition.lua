-- Synthetic, cooperative feature. No plugin/module unload or external effects.
return function(revision, version, options)
  options = options or {}
  local field = version == 1 and "count" or "total"
  return {
    stateVersion = version,
    initial = { [field] = 0, events = 0, owned_events = 0, ticks = 0, last = "none" },
    migrate = function(snapshot)
      if options.failMigration then error("fixture migration failure") end
      local state = snapshot.data
      return { [field] = state.count or state.total, events = state.events,
        owned_events = state.owned_events, ticks = state.ticks, last = state.last }
    end,
    activate = function(ctx, state)
      ctx:autocmd("PocGenerationOwned", function() state.owned_events = state.owned_events + 1 end)
      ctx:own(function()
        if options.cleanupLog then table.insert(options.cleanupLog, revision) end
        if options.failCleanup then error("fixture cleanup failure") end
      end)
      if options.failActivation then
        state[field] = -999 -- Mutate only the transferred copy, never the old state.
        error("fixture activation failure after managed acquisition")
      end
      return {
        state = state,
        run = function() state[field] = state[field] + 1; return revision end,
        read = function() return revision end,
        on_event = function() state.events = state.events + 1 end,
        on_timer = function() state.ticks = state.ticks + 1 end,
        request = function() return ctx:guard(function(value) state.last = value end) end,
      }
    end,
  }
end
