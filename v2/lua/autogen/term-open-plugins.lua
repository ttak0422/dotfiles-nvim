-- [nfnl] v2/fnl/term-open-plugins.fnl
vim.cmd("\ntnoremap <ESC> <c-\\><c-n><Plug>(esc)\nnnoremap <Plug>(esc)<ESC> i<ESC>\n         ")
local state = {}
local sync_input = nil
local set_option = vim.api.nvim_set_option_value
local function restore_winbars()
  for win, value in pairs((state.winbars or {})) do
    if vim.api.nvim_win_is_valid(win) then
      set_option("winbar", value, {win = win})
    else
    end
  end
  return nil
end
local function original_window(win)
  local zoom = package.loaded["neo-zoom"]
  return ((zoom and zoom.zoom_book and zoom.zoom_book[win]) or win)
end
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
      local function _4_()
        if ((vim.api.nvim_get_current_win() == win) and (vim.api.nvim_get_current_buf() == buf)) then
          return vim.cmd.startinsert()
        else
          return nil
        end
      end
      return vim.schedule(_4_)
    else
      return nil
    end
  else
    return nil
  end
end
local function send_input()
  local valid_3f = (state["term-buf"] and vim.api.nvim_buf_is_valid(state["term-buf"]) and (terminal_channel(state["term-buf"]) == state.chan))
  local text = (table.concat(vim.api.nvim_buf_get_lines(state.buf, 0, -1, false), "\n") .. "\r")
  local ok_3f, err
  if valid_3f then
    if (text == "\r") then
      ok_3f, err = true
    else
      ok_3f, err = pcall(vim.api.nvim_chan_send, state.chan, text)
    end
  else
    ok_3f, err = false, "terminal is unavailable"
  end
  if not ok_3f then
    vim.notify(("terminal input retained: " .. err), vim.log.levels.ERROR)
  else
  end
  return ok_3f
end
local function close_input(send_3f)
  sync_input()
  if (not send_3f or send_input()) then
    local buf = state.buf
    local win = state.win
    local term_buf = state["term-buf"]
    local term_win = state["term-win"]
    local term_cursor = state["term-cursor"]
    restore_winbars()
    if (win and vim.api.nvim_win_is_valid(win)) then
      pcall(vim.api.nvim_win_close, win, true)
    else
    end
    if (buf and vim.api.nvim_buf_is_valid(buf)) then
      pcall(vim.api.nvim_buf_delete, buf, {force = true})
    else
    end
    state = {}
    return focus_terminal(term_win, term_buf, term_cursor)
  else
    return nil
  end
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
  sync_input()
  if (state.win and vim.api.nvim_win_is_valid(state.win) and (vim.api.nvim_get_current_win() == state.win) and not vim.api.nvim_win_get_config(state.win).hide) then
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
  return {relative = "win", win = term_win, zindex = ((vim.api.nvim_win_get_config(term_win).zindex or 0) + 1), style = "minimal", border = "single", title = " SKK input ", title_pos = "center", width = width, height = height, row = row, col = col}
end
local function _16_()
  if (state.win and vim.api.nvim_win_is_valid(state.win)) then
    local zoom = package.loaded["neo-zoom"]
    local wins = vim.api.nvim_tabpage_list_wins(state.tab)
    local owns_3f
    local function _17_(win)
      return (win and vim.api.nvim_win_is_valid(win) and (vim.api.nvim_win_get_buf(win) == state["term-buf"]))
    end
    owns_3f = _17_
    local owner
    if owns_3f(state["home-win"]) then
      owner = state["home-win"]
    else
      if owns_3f(state["term-win"]) then
        owner = state["term-win"]
      else
        owner = nil
      end
    end
    local zoom_win = nil
    for _, win in ipairs(wins) do
      if (zoom and zoom.zoom_book and zoom.zoom_book[win]) then
        zoom_win = win
        if (owns_3f(win) and ((win == state["term-win"]) or (zoom.zoom_book[win] == state["home-win"]))) then
          owner = win
        else
        end
      else
      end
    end
    if (owner ~= state["term-win"]) then
      restore_winbars()
    else
    end
    state["term-win"] = owner
    local hide_3f = (not owner or (zoom_win and (owner ~= zoom_win)))
    local config
    if owner then
      local function _23_()
        return input_float_config(owner, math.max(10, math.min(80, (vim.api.nvim_win_get_width(owner) - 4))), 5)
      end
      config = vim.api.nvim_win_call(owner, _23_)
    else
      config = {relative = "editor", row = 0, col = 0}
    end
    config.hide = not not hide_3f
    if owner then
      if (state.winbars[owner] == nil) then
        state.winbars[owner] = vim.api.nvim_get_option_value("winbar", {win = owner, scope = "local"})
      else
      end
      local _26_
      if hide_3f then
        _26_ = state.winbars[owner]
      else
        _26_ = ""
      end
      set_option("winbar", _26_, {win = owner})
    else
    end
    vim.api.nvim_win_set_config(state.win, config)
    if (hide_3f and (vim.api.nvim_get_current_win() == state.win)) then
      local target = (zoom_win or owner)
      for _, win in ipairs(wins) do
        if (not target and (win ~= state.win) and (vim.api.nvim_win_get_config(win).relative == "")) then
          target = win
        else
        end
      end
      if target then
        vim.api.nvim_set_current_win(target)
      else
      end
    else
    end
  else
  end
  if (state.win and not vim.api.nvim_win_is_valid(state.win)) then
    restore_winbars()
    state = {}
    return nil
  else
    return nil
  end
end
sync_input = _16_
local sync_pending_3f = false
local function _34_()
  if not sync_pending_3f then
    sync_pending_3f = true
    local function _35_()
      sync_pending_3f = false
      return sync_input()
    end
    return vim.schedule(_35_)
  else
    return nil
  end
end
vim.api.nvim_create_autocmd({"WinEnter", "BufWinEnter", "WinClosed", "BufWipeout", "TabEnter"}, {group = vim.api.nvim_create_augroup("TerminalSkkInput", {clear = true}), callback = _34_})
local function open_input()
  if (state.win and vim.api.nvim_win_is_valid(state.win)) then
    if (not state["term-win"] and (vim.api.nvim_get_current_tabpage() == state.tab) and (vim.api.nvim_get_current_buf() == state["term-buf"])) then
      state["home-win"] = original_window(vim.api.nvim_get_current_win())
    else
    end
    sync_input()
    if vim.api.nvim_win_get_config(state.win).hide then
      return vim.notify("SKK input draft belongs to another terminal window", vim.log.levels.WARN)
    else
      vim.api.nvim_set_current_win(state.win)
      return vim.schedule(start_input)
    end
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
      state = {buf = buf, win = win, ["term-buf"] = term_buf, ["term-win"] = term_win, ["home-win"] = original_window(term_win), tab = vim.api.nvim_win_get_tabpage(term_win), winbars = {}, ["term-cursor"] = term_cursor, chan = chan}
      for name, value in pairs({bufhidden = "wipe", filetype = "skk-terminal-input"}) do
        set_option(name, value, {buf = buf})
      end
      vim.api.nvim_buf_set_name(buf, ("skk-terminal-input://" .. buf))
      for name, value in pairs({signcolumn = "no", foldcolumn = "0", winbar = "", number = false, relativenumber = false, wrap = false}) do
        set_option(name, value, {win = win})
      end
      sync_input()
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, {""})
      set_input_keymaps(buf)
      return vim.schedule(start_input)
    end
  end
end
return vim.keymap.set("t", "<C-g>", open_input, {noremap = true, silent = true, desc = "SKK input helper"})
