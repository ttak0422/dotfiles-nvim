-- [nfnl] Compiled from fnl/diffview.fnl by https://github.com/Olical/nfnl, do not edit.
local M = setmetatable({actions = require("diffview.actions")}, {__index = require("diffview")})
local icons = {folder_closed = "\238\151\191", folder_open = "\238\151\190"}
local signs = {fold_closed = "\239\145\160", fold_open = "\239\145\188", done = "\226\156\147"}
local view
do
  local default = {layout = "diff2_horizontal", winbar_info = false, disable_defaults = false}
  local merge_tool = {layout = "diff3_horizontal", disable_diagnostics = true, winbar_info = true}
  local file_history = {layout = "diff2_horizontal", winbar_info = false, disable_diagnostics = false}
  view = {default = default, merge_tool = merge_tool, file_history = file_history}
end
local file_panel
do
  local tree_options = {flatten_dirs = true, folder_statuses = "only_folded"}
  local win_config = {position = "left", width = 35, win_opts = {}}
  file_panel = {listing_style = "tree", tree_options = tree_options, win_config = win_config}
end
local file_history_panel
do
  local log_options = {git = {single_file = {diff_merges = "combined"}, multi_file = {diff_merges = "first-parent"}}, hg = {single_file = {}, multi_file = {}}}
  local win_config = {position = "bottom", height = 16, win_opts = {}}
  file_history_panel = {log_options = log_options, win_config = win_config}
end
local commit_log_panel = {win_config = {}}
local default_args = {DiffviewOpen = {}, DiffviewFileHistory = {}}
local hooks = {}
local keymaps
do
  local view0 = {{"n", "<tab>", M.actions.select_next_entry, {desc = "Open the diff for the next file"}}, {"n", "<s-tab>", M.actions.select_prev_entry, {desc = "Open the diff for the previous file"}}, {"n", "[f", M.actions.select_first_entry, {desc = "Open the diff for the first file"}}, {"n", "]f", M.actions.select_last_entry, {desc = "Open the diff for the last file"}}, {"n", "gf", M.actions.goto_file_edit, {desc = "Open the file in the previous tabpage"}}, {"n", "<leader>e", M.actions.focus_files, {desc = "Bring focus to the file panel"}}, {"n", "[x", M.actions.prev_conflict, {desc = "In the merge-tool: jump to the previous conflict"}}, {"n", "]x", M.actions.next_conflict, {desc = "In the merge-tool: jump to the next conflict"}}, {"n", "<leader>co", M.actions.conflict_choose("ours"), {desc = "Choose the OURS version of a conflict"}}, {"n", "<leader>ct", M.actions.conflict_choose("theirs"), {desc = "Choose the THEIRS version of a conflict"}}, {"n", "<leader>cb", M.actions.conflict_choose("base"), {desc = "Choose the BASE version of a conflict"}}, {"n", "<leader>ca", M.actions.conflict_choose("all"), {desc = "Choose all the versions of a conflict"}}, {"n", "<leader>dx", M.actions.conflict_choose("none"), {desc = "Delete the conflict region"}}, {"n", "<leader>cO", M.actions.conflict_choose_all("ours"), {desc = "Choose the OURS version of a conflict for the whole file"}}, {"n", "<leader>cT", M.actions.conflict_choose_all("theirs"), {desc = "Choose the OURS version of a conflict for the whole file"}}, {"n", "<leader>cB", M.actions.conflict_choose_all("base"), {desc = "Choose the BASE version of a conflict for the whole file"}}, {"n", "<leader>cA", M.actions.conflict_choose_all("all"), {desc = "Choose all the versions of a conflict for the whole file"}}, {"n", "<leader>dX", M.actions.conflict_choose_all("none"), {desc = "Delete the conflict region for the whole file"}}}
  local diff1 = {{"n", "g?", M.actions.help({"view", "diff1"}), {desc = "Open the help panel"}}}
  local diff2 = {{"n", "g?", M.actions.help({"view", "diff2"}), {desc = "Open the help panel"}}}
  local diff3 = {{{"n", "x"}, "2do", M.actions.diffget("ours"), {desc = "Obtain the diff hunk from the OURS version of the file"}}, {{"n", "x"}, "3do", M.actions.diffget("theirs"), {desc = "Obtain the diff hunk from the THEIRS version of the file"}}, {"n", "g?", M.actions.help({"view", "diff3"}), {desc = "Open the help panel"}}}
  local diff4 = {{{"n", "x"}, "1do", M.actions.diffget("base"), {desc = "Obtain the diff hunk from the BASE version of the file"}}, {{"n", "x"}, "2do", M.actions.diffget("ours"), {desc = "Obtain the diff hunk from the OURS version of the file"}}, {{"n", "x"}, "3do", M.actions.diffget("theirs"), {desc = "Obtain the diff hunk from the THEIRS version of the file"}}, {"n", "g?", M.actions.help({"view", "diff4"}), {desc = "Open the help panel"}}}
  local file_panel0 = {{"n", "j", M.actions.next_entry, {desc = "Bring the cursor to the next file entry"}}, {"n", "k", M.actions.prev_entry, {desc = "Bring the cursor to the previous file entry"}}, {"n", "<cr>", M.actions.select_entry, {desc = "Open the diff for the selected entry"}}, {"n", "s", M.actions.toggle_stage_entry, {desc = "Stage / unstage the selected entry"}}, {"n", "S", M.actions.stage_all, {desc = "Stage all entries"}}, {"n", "U", M.actions.unstage_all, {desc = "Unstage all entries"}}, {"n", "X", M.actions.restore_entry, {desc = "Restore entry to the state on the left side"}}, {"n", "zo", M.actions.open_fold, {desc = "Expand fold"}}, {"n", "zc", M.actions.close_fold, {desc = "Collapse fold"}}, {"n", "za", M.actions.toggle_fold, {desc = "Toggle fold"}}, {"n", "zR", M.actions.open_all_folds, {desc = "Expand all folds"}}, {"n", "zM", M.actions.close_all_folds, {desc = "Collapse all folds"}}, {"n", "<c-b>", M.actions.scroll_view(-0.25), {desc = "Scroll the view up"}}, {"n", "<c-f>", M.actions.scroll_view(0.25), {desc = "Scroll the view down"}}, {"n", "<tab>", M.actions.select_next_entry, {desc = "Open the diff for the next file"}}, {"n", "<s-tab>", M.actions.select_prev_entry, {desc = "Open the diff for the previous file"}}, {"n", "[F", M.actions.select_first_entry, {desc = "Open the diff for the first file"}}, {"n", "]F", M.actions.select_last_entry, {desc = "Open the diff for the last file"}}, {"n", "gf", M.actions.goto_file_edit, {desc = "Open the file in the previous tabpage"}}, {"n", "R", M.actions.refresh_files, {desc = "Update stats and entries in the file list"}}, {"n", "<leader>e", M.actions.focus_files, {desc = "Bring focus to the file panel"}}, {"n", "[x", M.actions.prev_conflict, {desc = "Go to the previous conflict"}}, {"n", "]x", M.actions.next_conflict, {desc = "Go to the next conflict"}}, {"n", "g?", M.actions.help("file_panel"), {desc = "Open the help panel"}}, {"n", "<leader>cO", M.actions.conflict_choose_all("ours"), {desc = "Choose the OURS version of a conflict for the whole file"}}, {"n", "<leader>cB", M.actions.conflict_choose_all("base"), {desc = "Choose the BASE version of a conflict for the whole file"}}, {"n", "<leader>cA", M.actions.conflict_choose_all("all"), {desc = "Choose all the versions of a conflict for the whole file"}}, {"n", "dX", M.actions.conflict_choose_all("none"), {desc = "Delete the conflict region for the whole file"}}}
  local file_history_panel0 = {{"n", "g!", M.actions.options, {desc = "Open the option panel"}}, {"n", "y", M.actions.copy_hash, {desc = "Copy the commit hash of the entry under the cursor"}}, {"n", "X", M.actions.restore_entry, {desc = "Restore file to the state from the selected entry"}}, {"n", "j", M.actions.next_entry, {desc = "Bring the cursor to the next file entry"}}, {"n", "k", M.actions.prev_entry, {desc = "Bring the cursor to the previous file entry"}}, {"n", "<cr>", M.actions.select_entry, {desc = "Open the diff for the selected entry"}}, {"n", "<c-b>", M.actions.scroll_view(-0.25), {desc = "Scroll the view up"}}, {"n", "<c-f>", M.actions.scroll_view(0.25), {desc = "Scroll the view down"}}, {"n", "<tab>", M.actions.select_next_entry, {desc = "Open the diff for the next file"}}, {"n", "<s-tab>", M.actions.select_prev_entry, {desc = "Open the diff for the previous file"}}, {"n", "[F", M.actions.select_first_entry, {desc = "Open the diff for the first file"}}, {"n", "]F", M.actions.select_last_entry, {desc = "Open the diff for the last file"}}, {"n", "gf", M.actions.goto_file_edit, {desc = "Open the file in the previous tabpage"}}, {"n", "<leader>e", M.actions.focus_files, {desc = "Bring focus to the file panel"}}, {"n", "g?", M.actions.help("file_history_panel"), {desc = "Open the help panel"}}}
  local option_panel = {{"n", "<tab>", M.actions.select_entry, {desc = "Change the current option"}}, {"n", "q", M.actions.close, {desc = "Close the panel"}}, {"n", "g?", M.actions.help("option_panel"), {desc = "Open the help panel"}}}
  local help_panel = {{"n", "q", M.actions.close, {desc = "Close help menu"}}, {"n", "<esc>", M.actions.close, {desc = "Close help menu"}}}
  keymaps = {disable_defaults = true, view = view0, diff1 = diff1, diff2 = diff2, diff3 = diff3, diff4 = diff4, file_panel = file_panel0, file_history_panel = file_history_panel0, option_panel = option_panel, help_panel = help_panel}
end
return M.setup({git_cmd = {"git"}, hg_cmd = {"hg"}, use_icons = true, show_help_hints = true, watch_index = true, icons = icons, signs = signs, view = view, file_panel = file_panel, file_history_panel = file_history_panel, commit_log_panel = commit_log_panel, default_args = default_args, hooks = hooks, keymaps = keymaps, diff_binaries = false, enhanced_diff_hl = false})
