-- [nfnl] v2/fnl/which-key.fnl
local wk = require("which-key")
local function delay(ctx)
  if ctx.plugin then
    return 50
  else
    return 200
  end
end
local icons = {mappins = true, rules = false}
return wk.setup({preset = "helix", delay = delay, icons = icons})
