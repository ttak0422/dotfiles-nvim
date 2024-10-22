-- [nfnl] Compiled from fnl/gitsigns.fnl by https://github.com/Olical/nfnl, do not edit.
do
  local M = require("gitsigns")
  local current_line_blame_opts = {virt_text = true, virt_text_pos = "eol", virt_text_priority = 3000, delay = 1000, ignore_whitespace = false}
  local preview_config = {border = "none", style = "minimal", relative = "cursor", row = 0, col = 1}
  M.setup({signcolumn = true, numhl = true, current_line_blame = true, current_line_blame_formatter = "<author> <author_time:%Y-%m-%d> - <summary>", sign_priority = 6, update_debounce = 1000, max_file_length = 40000, current_line_blame_opts = current_line_blame_opts, preview_config = preview_config})
end
local function _1_()
  local wins = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local filetype = vim.api.nvim_buf_get_option(buf, "filetype")
    if (filetype == "gitsigns-blame") then
      wins[(#wins + 1)] = win
    else
    end
  end
  if (#wins ~= 0) then
    for _, win in ipairs(wins) do
      vim.api.nvim_win_close(win, true)
    end
    return nil
  else
    return vim.cmd("Gitsigns blame")
  end
end
return vim.api.nvim_create_user_command("ToggleGitBlame", _1_, {})
