-- [nfnl] v2/fnl/hydra.fnl
local hydra = require("hydra")
local float_opts = {border = "single"}
hydra.setup({timeout = false})
local heads = {{"H", "<C-v>h:VBox<CR>"}, {"J", "<C-v>j:VBox<CR>"}, {"K", "<C-v>k:VBox<CR>"}, {"L", "<C-v>l:VBox<CR>"}, {"r", ":VBoxD<CR>", {mode = "v"}}, {"f", ":VBox<CR>", {mode = "v"}}, {"v", ":VBoxH<CR>", {mode = "v"}}, {"<Esc>", nil, {desc = "close", exit = true}}}
local config
local function _1_()
  return vim.cmd("setlocal ve=all")
end
local function _2_()
  return vim.cmd("setlocal ve=")
end
config = {invoke_on_body = true, color = "pink", on_enter = _1_, on_exit = _2_, hint = {type = "window", position = "bottom-right", float_opts = float_opts}}
local hint = ":Move    Select region with <C-v>\n-------  -------------------------\n   _K_     _r_: surround double\n _H_   _L_   _f_: surround single\n   _J_     _v_: surround bold"
return hydra({name = "Draw Diagram", mode = "n", body = "<Leader>V", heads = heads, config = config, hint = hint})
