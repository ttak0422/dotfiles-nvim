-- [nfnl] Compiled from fnl/oil.fnl by https://github.com/Olical/nfnl, do not edit.
do
  local M = require("oil")
  local columns = {"icon"}
  local border = "none"
  local buf_options = {bufhidden = "hide", buflisted = false}
  local win_options = {signcolumn = "number", foldcolumn = "0", conceallevel = 3, concealcursor = "nvic", cursorcolumn = false, list = false, spell = false, wrap = false}
  local keymaps = {["g?"] = "actions.show_help", ["<CR>"] = "actions.select", e = "actions.select", ["<C-v>"] = "actions.select_vsplit", ["<C-s>"] = "actions.select_split", ["<C-t>"] = "actions.select_tab", ["<C-p>"] = "actions.preview", q = "actions.close", ["<C-c>"] = "actions.close", R = "actions.refresh", H = "actions.parent", L = "actions.select"}
  local keymaps_help = {border = border}
  local view_options
  local function _1_(_name, _bufnr)
    return false
  end
  local function _2_(_name, _bufnr)
    return false
  end
  view_options = {show_hidden = true, is_hidden_file = _1_, is_always_hidden = _2_, sort = {{"type", "asc"}, {"name", "asc"}}}
  local preview = {max_width = 0.9, min_width = {40, 0.4}, width = nil, max_height = 0.9, min_height = {5, 0.1}, height = nil, border = border, win_options = {winblend = 0}, update_on_cursor_moved = true}
  local float = {border = "single"}
  local progress = {max_width = 0.9, min_width = {40, 0.4}, width = nil, max_height = {10, 0.9}, min_height = {5, 0.1}, height = nil, border = border, minimized_border = "none", win_options = {winblend = 0}}
  local ssh = {border = "none"}
  local lsp_file_methods = {timeout_ms = 1000, autosave_changes = false}
  M.setup({delete_to_trash = true, prompt_save_on_select_new_entry = true, cleanup_delay_ms = 2000, constrain_cursor = "editable", lsp_file_methods = lsp_file_methods, columns = columns, buf_options = buf_options, win_options = win_options, keymaps = keymaps, keymaps_help = keymaps_help, view_options = view_options, preview = preview, float = float, progress = progress, ssh = ssh, default_file_explorer = false, experimental_watch_for_changes = false, skip_confirm_for_simple_edits = false, use_default_keymaps = false})
end
local M = require("oil-vcs-status")
local status_const = require("oil-vcs-status.constant.status")
local StatusType = status_const.StatusType
local status_symbol = {[StatusType.Added] = "\239\145\151", [StatusType.Copied] = "\243\176\134\143", [StatusType.Deleted] = "\239\145\152", [StatusType.Ignored] = "\238\153\168", [StatusType.Modified] = "\238\171\158", [StatusType.Renamed] = "\239\145\154", [StatusType.TypeChanged] = "\243\176\137\186", [StatusType.Unmodified] = " ", [StatusType.Unmerged] = "\238\171\190", [StatusType.Untracked] = "\238\169\191", [StatusType.External] = "\239\145\165", [StatusType.UpstreamAdded] = "\243\176\136\158", [StatusType.UpstreamCopied] = "\243\176\136\162", [StatusType.UpstreamDeleted] = "\239\128\141", [StatusType.UpstreamIgnored] = " ", [StatusType.UpstreamModified] = "\243\176\143\171", [StatusType.UpstreamRenamed] = "\238\137\189", [StatusType.UpstreamTypeChanged] = "\243\177\167\182", [StatusType.UpstreamUnmodified] = " ", [StatusType.UpstreamUnmerged] = "\239\147\137", [StatusType.UpstreamUntracked] = " ", [StatusType.UpstreamExternal] = "\239\133\140"}
local status_priority = {[StatusType.UpstreamIgnored] = 0, [StatusType.Ignored] = 0, [StatusType.UpstreamUntracked] = 1, [StatusType.Untracked] = 1, [StatusType.UpstreamUnmodified] = 2, [StatusType.Unmodified] = 2, [StatusType.UpstreamExternal] = 2, [StatusType.External] = 2, [StatusType.UpstreamCopied] = 3, [StatusType.UpstreamRenamed] = 3, [StatusType.UpstreamTypeChanged] = 3, [StatusType.UpstreamDeleted] = 4, [StatusType.UpstreamModified] = 4, [StatusType.UpstreamAdded] = 4, [StatusType.UpstreamUnmerged] = 5, [StatusType.Copied] = 13, [StatusType.Renamed] = 13, [StatusType.TypeChanged] = 13, [StatusType.Deleted] = 14, [StatusType.Modified] = 14, [StatusType.Added] = 14, [StatusType.Unmerged] = 15}
local vcs_specific = {git = {status_update_debounce = 200}}
return M.setup({[":fs_event_debounce"] = 500, status_symbol = status_symbol, status_priority = status_priority, vcs_specific = vcs_specific})
