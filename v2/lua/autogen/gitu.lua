-- [nfnl] v2/fnl/gitu.fnl
local function gitu()
  local wins = vim.api.nvim_list_wins()
  local win_count = #wins
  local did_split = (win_count == 1)
  if did_split then
    local width = vim.o.columns
    local height = vim.o.lines
    if ((width / height) > 2.5) then
      vim.cmd("vsplit")
    else
      vim.cmd("split")
    end
  else
  end
  vim.cmd("terminal gitu")
  local buf = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()
  local function _3_()
    local status = vim.v.event.status
    if (status == 0) then
      local function _4_()
        if vim.api.nvim_buf_is_valid(buf) then
          if did_split then
            if vim.api.nvim_win_is_valid(win) then
              return vim.api.nvim_win_close(win, true)
            else
              return nil
            end
          else
            return require("snacks").bufdelete({buf = buf, force = true})
          end
        else
          return nil
        end
      end
      return vim.schedule(_4_)
    else
      return vim.notify(("gitu exited with code " .. status), vim.log.levels.WARN)
    end
  end
  vim.api.nvim_create_autocmd("TermClose", {buffer = buf, callback = _3_})
  vim.bo[buf]["buflisted"] = false
  vim.bo[buf]["bufhidden"] = "wipe"
  local function _9_()
    local function _10_()
      if (vim.api.nvim_buf_is_valid(buf) and (vim.api.nvim_get_current_buf() == buf)) then
        return vim.cmd("startinsert")
      else
        return nil
      end
    end
    return vim.schedule(_10_)
  end
  vim.api.nvim_create_autocmd("BufEnter", {buffer = buf, callback = _9_})
  return vim.cmd("startinsert")
end
vim.api.nvim_create_user_command("Gitu", gitu, {})
local function _12_()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local name = vim.api.nvim_buf_get_name(buf)
    if name:match("term://.*gitu$") then
      require("snacks").bufdelete({buf = buf, force = true})
    else
    end
  end
  return nil
end
return vim.api.nvim_create_user_command("GituClear", _12_, {})
