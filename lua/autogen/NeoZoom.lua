-- [nfnl] Compiled from fnl/NeoZoom.fnl by https://github.com/Olical/nfnl, do not edit.
local function _1_()
  vim.wo.wrap = true
  return nil
end
return require("neo-zoom").setup({popup = {enabled = true}, exclude_buftypes = {"terminal"}, winopts = {offset = {width = 150, height = 0.85}, border = "none"}, presets = {{filetypes = {"dapui_.*", "dap-repl"}, winopts = {offset = {top = 0.02, left = 0.26, width = 0.74, height = 0.45}}}, {filetypes = {"markdown"}, callbacks = {_1_}}}})
