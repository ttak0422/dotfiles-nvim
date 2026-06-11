-- [nfnl] v2/fnl/term-open-plugins.fnl
vim.cmd("\ntnoremap <ESC> <c-\\><c-n><Plug>(esc)\nnnoremap <Plug>(esc)<ESC> i<ESC>\n         ")
local state = {}
local set_option = vim.api.nvim_set_option_value
local function terminal_channel(buf)
  local ok_3f, chan = pcall(vim.api.nvim_buf_get_var, buf, "terminal_job_id")
  if (ok_3f and (type(chan) == "number")) then
    return chan
  else
    return nil
  end
end
local function focus_terminal(win, buf, cursor)
  if (win and vim.api.nvim_win_is_valid(win)) then
    vim.api.nvim_set_current_win(win)
    if cursor then
      pcall(vim.api.nvim_win_set_cursor, win, cursor)
    else
    end
    if (buf and vim.api.nvim_buf_is_valid(buf) and (vim.bo[buf].buftype == "terminal")) then
      local function _3_()
        return vim.cmd.startinsert()
      end
      return vim.schedule(_3_)
    else
      return nil
    end
  else
    return nil
  end
end
local function close_input(send_3f)
  local buf = state.buf
  local win = state.win
  local term_buf = state["term-buf"]
  local term_win = state["term-win"]
  local term_cursor = state["term-cursor"]
  local chan = state.chan
  local lines
  if (buf and vim.api.nvim_buf_is_valid(buf)) then
    lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  else
    lines = {}
  end
  if (win and vim.api.nvim_win_is_valid(win)) then
    pcall(vim.api.nvim_win_close, win, true)
  else
  end
  if (buf and vim.api.nvim_buf_is_valid(buf)) then
    pcall(vim.api.nvim_buf_delete, buf, {force = true})
  else
  end
  if (term_win and vim.api.nvim_win_is_valid(term_win)) then
    local function _9_()
      return vim.cmd("setlocal winbar<")
    end
    pcall(vim.api.nvim_win_call, term_win, _9_)
  else
  end
  state = {}
  if send_3f then
    local text = (table.concat(lines, "\n") .. "\r")
    if (text ~= "\r") then
      local ok_3f, err = pcall(vim.api.nvim_chan_send, chan, text)
      if not ok_3f then
        vim.notify(("terminal input failed: " .. err), vim.log.levels.ERROR)
      else
      end
    else
    end
  else
  end
  return focus_terminal(term_win, term_buf, term_cursor)
end
local function accept_input()
  return close_input(true)
end
local function cancel_input()
  return close_input(false)
end
local function enable_skkeleton()
  local keys = vim.api.nvim_replace_termcodes("<Plug>(skkeleton-enable)", true, false, true)
  return vim.api.nvim_feedkeys(keys, "m", false)
end
local function set_input_keymaps(buf)
  local keymap_opts = {buffer = buf, noremap = true, nowait = true, silent = true}
  vim.keymap.set("i", "<C-c>", cancel_input, keymap_opts)
  vim.keymap.set("n", "<C-c>", cancel_input, keymap_opts)
  vim.keymap.set("n", "<leader>q", cancel_input, keymap_opts)
  vim.keymap.set("n", "<leader>Q", cancel_input, keymap_opts)
  vim.keymap.set("n", "<C-s>", accept_input, keymap_opts)
  return vim.keymap.set("i", "<C-s>", accept_input, keymap_opts)
end
local function start_input()
  if (state.win and vim.api.nvim_win_is_valid(state.win)) then
    vim.api.nvim_set_current_win(state.win)
    vim.cmd.startinsert()
    return enable_skkeleton()
  else
    return nil
  end
end
local function input_float_config(term_win, width, height)
  local cursor_row = (vim.fn.winline() - 1)
  local cursor_col = (vim.fn.wincol() - 1)
  local win_height = vim.api.nvim_win_get_height(term_win)
  local win_width = vim.api.nvim_win_get_width(term_win)
  local border_size = 2
  local row
  if ((cursor_row + 1 + height + border_size) <= win_height) then
    row = (cursor_row + 1)
  else
    row = math.max(0, (cursor_row - height - border_size))
  end
  local col = math.min(cursor_col, math.max(0, (win_width - width - border_size)))
  return {relative = "win", win = term_win, style = "minimal", border = "single", title = " SKK input ", title_pos = "center", width = width, height = height, row = row, col = col}
end
local function open_input()
  if (state.win and vim.api.nvim_win_is_valid(state.win)) then
    vim.api.nvim_set_current_win(state.win)
    return vim.schedule(start_input)
  else
    local term_buf = vim.api.nvim_get_current_buf()
    local term_win = vim.api.nvim_get_current_win()
    local term_cursor = vim.api.nvim_win_get_cursor(term_win)
    local chan = terminal_channel(term_buf)
    if not chan then
      return vim.notify("Terminal SKK input is only available in terminal buffers", vim.log.levels.WARN)
    else
      local width = math.max(10, math.min(80, (vim.api.nvim_win_get_width(term_win) - 4)))
      local height = 5
      local buf = vim.api.nvim_create_buf(false, true)
      local win = vim.api.nvim_open_win(buf, true, input_float_config(term_win, width, height))
      state = {buf = buf, win = win, ["term-buf"] = term_buf, ["term-win"] = term_win, ["term-cursor"] = term_cursor, chan = chan}
      for name, value in pairs({bufhidden = "wipe", filetype = "skk-terminal-input"}) do
        set_option(name, value, {buf = buf})
      end
      vim.api.nvim_buf_set_name(buf, ("skk-terminal-input://" .. buf))
      for name, value in pairs({signcolumn = "no", foldcolumn = "0", winbar = "", number = false, relativenumber = false, wrap = false}) do
        set_option(name, value, {win = win})
      end
      set_option("winbar", "", {win = term_win})
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, {""})
      set_input_keymaps(buf)
      return vim.schedule(start_input)
    end
  end
end
return vim.keymap.set("t", "<C-g>", open_input, {noremap = true, silent = true, desc = "SKK input helper"})
