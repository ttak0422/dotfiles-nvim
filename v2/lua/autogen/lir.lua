-- [nfnl] v2/fnl/lir.fnl
local lir = require("lir")
local git = require("lir.git_status")
local actions = require("lir.actions")
local ignore = {".DS_Store"}
local devicons = {enable = true, highlight_dirname = true}
local mappings = {e = actions.edit, ["<CR>"] = actions.edit, L = actions.edit, H = actions.up, q = actions.quit, ["<C-c>"] = actions.quit, a = actions.newfile, r = actions.rename, d = actions.wipeout}
local float
local function _1_()
  return {relative = "cursor", row = 1, col = 0, width = 40, height = 12, style = "minimal", border = "single"}
end
float = {winblend = 0, curdir_window = {highlight_dirname = true, enable = false}, win_opts = _1_, hide_cursor = true}
lir.setup({show_hidden_files = true, ignore = ignore, devicons = devicons, mappings = mappings, float = float})
return git.setup({show_ignored = false})
