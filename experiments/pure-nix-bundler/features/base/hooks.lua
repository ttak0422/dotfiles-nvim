return {
  setup = function(ctx)
    if ctx.options.failSetup then
      ctx:own(function() ctx.state.cleaned = true end)
      error("fixture setup failure")
    end
    ctx.runtime.trace[#ctx.runtime.trace + 1] = "base.setup"
  end,
}
