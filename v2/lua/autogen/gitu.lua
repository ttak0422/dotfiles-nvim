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
  do
    local buf = vim.api.nvim_get_current_buf()
    local win = vim.api.nvim_get_current_win()
    local function _3_()
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
    end
    vim.api.nvim_create_autocmd("TermClose", {buffer = buf, callback = _3_})
  end
  return vim.cmd("startinsert")
end
vim.api.nvim_create_user_command("Gitu", gitu, {})
local function _8_()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local name = vim.api.nvim_buf_get_name(buf)
    if name:match("term://.*gitu$") then
      require("snacks").bufdelete({buf = buf, force = true})
    else
    end
  end
  return nil
end
return vim.api.nvim_create_user_command("GituClear", _8_, {})
