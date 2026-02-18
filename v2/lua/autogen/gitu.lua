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
local opts = {win = {position = "float", width = 0.75, fixbuf = false}}
local function open()
  if (terminal and terminal:buf_valid()) then
    if not win_valid_3f(terminal.win) then
      terminal:toggle()
    else
    end
    terminal:focus()
    if (win_valid_3f(terminal.win) and buf_term_3f(terminal.buf)) then
      local function _2_()
        return vim.cmd.startinsert()
      end
      return vim.api.nvim_win_call(terminal.win, _2_)
    else
      return nil
    end
  else
    local term_instance = Snacks.terminal.open(cmd, opts)
    if (term_instance and term_instance:buf_valid()) then
      do
        local function _4_()
          if (terminal == term_instance) then
            terminal = nil
            return nil
          else
            return nil
          end
        end
        term_instance:on("TermClose", _4_, {buf = true})
        local function _6_()
          local function _7_()
            if ((terminal == term_instance) and term_instance:win_valid() and not (vim.api.nvim_get_current_buf() == term_instance.buf)) then
              return term_instance:hide()
            else
              return nil
            end
          end
          return vim.schedule(_7_)
        end
        term_instance:on("BufLeave", _6_, {buf = true})
        local function _9_()
          if (terminal == term_instance) then
            terminal = nil
            return nil
          else
            return nil
          end
        end
        term_instance:on("BufWipeout", _9_, {buf = true})
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
    terminal = nil
    return open()
  end
end
return vim.api.nvim_create_user_command("Gitu", toggle, {})
