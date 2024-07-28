-- [nfnl] Compiled from fnl/hydra.fnl by https://github.com/Olical/nfnl, do not edit.
local Hydra = require("hydra")
local KeymapUtil = require("hydra.keymap-util")
local Cmd = KeymapUtil.cmd
local float_opts = {border = "none"}
Hydra.setup({foreign_keys = nil, color = "red", timeout = 10000, hint = {show_name = true, position = {"bottom"}, offset = 0, float_opts = {}}, on_enter = nil, on_exit = nil, on_key = nil, debug = false, invoke_on_body = false, exit = false})
local heads = {{"H", "<C-v>h:VBox<CR>"}, {"J", "<C-v>j:VBox<CR>"}, {"K", "<C-v>k:VBox<CR>"}, {"L", "<C-v>l:VBox<CR>"}, {"f", ":VBox<CR>", {mode = "v"}}, {"<Esc>", nil, {desc = "close", exit = true}}}
local config
local function _1_()
  return vim.cmd("setlocal ve=all")
end
local function _2_()
  return vim.cmd("setlocal ve=")
end
config = {invoke_on_body = true, color = "pink", on_enter = _1_, on_exit = _2_, hint = {type = "window", position = "bottom-right", float_opts = float_opts}}
local hint = ":Move    Select region with <C-v>\n-------  -------------------------\n   _K_\n _H_   _L_   _f_: surround it with box\n   _J_"
return Hydra({name = "Draw Diagram", mode = "n", body = "<Leader>V", heads = heads, config = config, hint = hint})
