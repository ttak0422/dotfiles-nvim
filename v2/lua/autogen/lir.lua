-- [nfnl] Compiled from v2/fnl/lir.fnl by https://github.com/Olical/nfnl, do not edit.
local lir = require("lir")
local git = require("lir.git_status")
local actions = require("lir.actions")
local ignore = {".DS_Store"}
local devicons = {enable = true, highlight_dirname = true}
local mappings = {e = actions.edit, ["<CR>"] = actions.edit, L = actions.edit, H = actions.up, q = actions.quit, ["<C-c>"] = actions.quit, a = actions.newfile, r = actions.rename, d = actions.wipeout}
local float
local function _1_()
  local width = math.floor((vim.o.columns / 2))
  local height = math.floor((vim.o.lines / 2))
  return {relative = "editor", width = width, height = height, style = "minimal", border = "none"}
end
float = {winblend = 0, curdir_window = {enable = true, highlight_dirname = true}, win_opts = _1_, hide_cursor = true}
lir.setup({show_hidden_files = true, ignore = ignore, devicons = devicons, mappings = mappings, float = float})
return git.setup({show_ignored = false})
