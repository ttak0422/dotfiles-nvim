-- [nfnl] Compiled from fnl/lir.fnl by https://github.com/Olical/nfnl, do not edit.
local M = setmetatable({git = require("lir.git_status"), actions = require("lir.actions")}, {__index = require("lir")})
local ignore = {".DS_Store"}
local devicons = {enable = true, highlight_dirname = true}
local mappings = {e = M.actions.edit, ["<CR>"] = M.actions.edit, L = M.actions.edit, H = M.actions.up, q = M.actions.quit, ["<C-c>"] = M.actions.quit, a = M.actions.newfile, r = M.actions.rename, d = M.actions.wipeout}
local float
local function _1_()
  local width = math.floor((vim.o.columns / 2))
  local height = math.floor((vim.o.lines / 2))
  return {relative = "editor", width = width, height = height, style = "minimal", border = "none"}
end
float = {winblend = 0, curdir_window = {enable = true, highlight_dirname = true}, win_opts = _1_, hide_cursor = true}
M.setup({show_hidden_files = true, ignore = ignore, devicons = devicons, mappings = mappings, float = float})
return M.git.setup({show_ignored = false})
