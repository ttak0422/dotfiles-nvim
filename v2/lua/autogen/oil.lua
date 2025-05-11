-- [nfnl] Compiled from v2/fnl/oil.fnl by https://github.com/Olical/nfnl, do not edit.
local M = require("oil")
local function _1_(_name, _bufnr)
  return false
end
local function _2_(_name, _bufnr)
  return false
end
return M.setup({columns = {"icon", "permissions", "size", "mtime"}, delete_to_trash = true, lsp_file_methods = {timeout_ms = 5000}, view_options = {show_hidden = true, is_hidden_file = _1_, is_always_hidden = _2_, sort = {{"type", "asc"}, {"name", "asc"}}}, keymaps = {["g?"] = "actions.show_help", ["<CR>"] = "actions.select", e = "actions.select", ["<C-v>"] = "actions.select_vsplit", ["<C-s>"] = "actions.select_split", ["<C-t>"] = "actions.select_tab", ["<C-p>"] = "actions.preview", q = "actions.close", ["<C-c>"] = "actions.close", R = "actions.refresh", H = "actions.parent", L = "actions.select"}, keymaps_help = {border = "none"}, default_file_explorer = false, use_default_keymaps = false})
