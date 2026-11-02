return {
  prepare = function(ctx) ctx.runtime.trace[#ctx.runtime.trace + 1] = "picker.prepare" end,
  setup = function(ctx) ctx.runtime.trace[#ctx.runtime.trace + 1] = "picker.setup" end,
}
