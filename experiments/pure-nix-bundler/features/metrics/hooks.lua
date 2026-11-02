return {
  attach = function(ctx)
    ctx.state.cleanup = {}
    ctx:own(function() table.insert(ctx.state.cleanup, "first") end)
    ctx:own(function() table.insert(ctx.state.cleanup, "second") end)
  end,
  update = function(ctx)
    ctx:latest("analysis", function(done)
      -- Controlled asynchronous provider: tests deliver replies in any order.
      local request = { done = done, cancelled = false }
      ctx.runtime.requests[#ctx.runtime.requests + 1] = request
      return function() request.cancelled = true end
    end, function(value) ctx.state.value = value end)
  end,
}
