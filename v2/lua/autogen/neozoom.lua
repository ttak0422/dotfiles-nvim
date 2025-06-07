-- [nfnl] v2/fnl/neozoom.fnl
local zoom = require("neo-zoom")
local winopts = {offset = {width = 180, height = 0.9}, border = "single"}
local exclude_buftypes = {}
local presets = {{filetypes = {"dapui_.*", "dap-repl"}, winopts = {offset = {top = 0.02, left = 0.26, width = 0.74, height = 0.6}}}}
local callbacks
local function _1_()
  for _, command in ipairs({"hi link NeoZoomFloatBg Normal", "hi link NeoZoomFloatBorder Normal", "set winhl=Normal:NeoZoomFloatBg,FloatBorder:NeoZoomFloatBorder"}) do
    vim.cmd(command)
  end
  return nil
end
callbacks = {_1_}
return zoom.setup({winopts = winopts, exclude_buftypes = exclude_buftypes, presets = presets, callbacks = callbacks})
