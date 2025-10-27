-- [nfnl] v2/fnl/gitu.fnl
local Snacks = require("snacks")
local terminal = nil
local function win_valid_3f(win)
  return (win and vim.api.nvim_win_is_valid(win))
end
local function buf_valid_3f(buf)
  return (buf and vim.api.nvim_buf_is_valid(buf))
end
local function buf_term_3f(buf)
  return (buf and (vim.api.nvim_buf_get_option(buf, "buftype") == "terminal"))
end
local cmd = "gitu"
local opts = {win = {position = "float", width = 0.4}}
local function close()
  if (terminal and terminal:buf_valid()) then
    return vim.api.nvim_win_close(terminal.win, false)
  else
    return nil
  end
end
local function open()
  if (terminal and terminal:buf_valid()) then
    if not win_valid_3f(terminal.win) then
      terminal:toggle()
    else
    end
    terminal:focus()
    if (win_valid_3f(terminal.win) and buf_term_3f(terminal.buf)) then
      local function _3_()
        return vim.cmd.startinsert()
      end
      return vim.api.nvim_win_call(terminal.win, _3_)
    else
      return nil
    end
  else
    local term_instance = Snacks.terminal.open(cmd, opts)
    if (term_instance and term_instance:buf_valid()) then
      do
        local function _5_()
          terminal = nil
          local function _6_()
            if term_instance then
              return term_instance:close({buf = true})
            else
              return nil
            end
          end
          return vim.schedule(_6_)
        end
        term_instance:on("TermClose", _5_, {buf = true})
        local function _8_()
          terminal = nil
          return nil
        end
        term_instance:on("BufWipeout", _8_, {buf = true})
        local function _9_()
          return vim.defer_fn(close, 20)
        end
        term_instance:on("BufLeave", _9_, {buf = true})
      end
      terminal = term_instance
      return nil
    else
      vim.notify("Failed to open gitu", vim.log.levels.ERROR)
      terminal = nil
      return nil
    end
  end
end
local function toggle()
  if (terminal and terminal:buf_valid()) then
    if terminal:win_valid() then
      vim.notfiy("terminal visible")
      local current_win_id = vim.api.nvim_get_current_win()
      local target_win_id = terminal.win
      if (target_win_id == current_win_id) then
        return terminal:toggle()
      else
        vim.api.nvim_set_current_win(target_win_id)
        if (buf_valid_3f(terminal.buf) and buf_term_3f(terminal.buf)) then
          return vim.cmd.startinsert()
        else
          return nil
        end
      end
    else
      return terminal:toggle()
    end
  else
    return open()
  end
end
return vim.api.nvim_create_user_command("Gitu", toggle, {})
