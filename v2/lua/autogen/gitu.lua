-- [nfnl] v2/fnl/gitu.fnl
local augroup = vim.api.nvim_create_augroup("ttak-gitu", {clear = false})
local gitu_pattern = "term://.*:gitu$"
local function gitu_buffer_3f(buf)
  local and_1_ = vim.api.nvim_buf_is_valid(buf)
  if and_1_ then
    local or_2_ = (true == vim.b[buf].gitu)
    if not or_2_ then
      local name = vim.api.nvim_buf_get_name(buf)
      or_2_ = (name:match(gitu_pattern) and true)
    end
    and_1_ = or_2_
  end
  return and_1_
end
local function gitu_running_buffer_3f(buf)
  return (gitu_buffer_3f(buf) and (true == vim.b[buf].gitu_running))
end
local function normal_win_count()
  local count = 0
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if ("" == vim.api.nvim_win_get_config(win).relative) then
      count = (count + 1)
    else
    end
  end
  return count
end
local function split_for_gitu()
  local width = vim.o.columns
  local height = vim.o.lines
  if ((width / height) > 2.5) then
    return vim.cmd("vsplit")
  else
    return vim.cmd("split")
  end
end
local function startinsert_if_current(buf)
  local function _6_()
    if (vim.api.nvim_buf_is_valid(buf) and (vim.api.nvim_get_current_buf() == buf)) then
      return vim.cmd("startinsert")
    else
      return nil
    end
  end
  return vim.schedule(_6_)
end
local function with_editor_origin(win, buf, f)
  local prev_editor_win = vim.env.NVIM_EDITOR_WIN
  local prev_editor_buf = vim.env.NVIM_EDITOR_BUF
  vim.env.NVIM_EDITOR_WIN = tostring(win)
  vim.env.NVIM_EDITOR_BUF = tostring(buf)
  local ok_3f, result = pcall(f)
  vim.env.NVIM_EDITOR_WIN = prev_editor_win
  vim.env.NVIM_EDITOR_BUF = prev_editor_buf
  if ok_3f then
    return result
  else
    return error(result)
  end
end
local function focus_gitu_buffer(buf)
  do
    local wins = vim.fn.win_findbuf(buf)
    if (#wins > 0) then
      vim.api.nvim_set_current_win(wins[1])
    else
      if (normal_win_count() == 1) then
        split_for_gitu()
      else
      end
      vim.api.nvim_win_set_buf(0, buf)
    end
  end
  return startinsert_if_current(buf)
end
local function delete_gitu_buffer(buf)
  local function _11_()
    return require("snacks").bufdelete({buf = buf, force = true})
  end
  return pcall(_11_)
end
local function close_gitu_buffer(buf, win, did_split)
  if vim.api.nvim_buf_is_valid(buf) then
    if (did_split and vim.api.nvim_win_is_valid(win)) then
      local ok_3f = pcall(vim.api.nvim_win_close, win, true)
      if not ok_3f then
        return delete_gitu_buffer(buf)
      else
        return nil
      end
    else
      return delete_gitu_buffer(buf)
    end
  else
    return nil
  end
end
local function gitu()
  local running_buf = vim.iter(vim.api.nvim_list_bufs()):find(gitu_running_buffer_3f)
  if running_buf then
    return focus_gitu_buffer(running_buf)
  else
    local did_split = (normal_win_count() == 1)
    if did_split then
      split_for_gitu()
    else
    end
    vim.cmd("enew")
    local buf = vim.api.nvim_get_current_buf()
    local win = vim.api.nvim_get_current_win()
    vim.api.nvim_buf_set_var(buf, "gitu", true)
    vim.api.nvim_buf_set_var(buf, "gitu_running", true)
    vim.api.nvim_set_option_value("buflisted", false, {buf = buf})
    vim.api.nvim_set_option_value("bufhidden", "wipe", {buf = buf})
    local function _16_()
      return startinsert_if_current(buf)
    end
    vim.api.nvim_create_autocmd("BufEnter", {group = augroup, buffer = buf, callback = _16_})
    local job
    local function _17_()
      local function _18_(_, status, _0)
        if vim.api.nvim_buf_is_valid(buf) then
          vim.api.nvim_buf_set_var(buf, "gitu_running", false)
        else
        end
        if (status == 0) then
          local function _20_()
            return close_gitu_buffer(buf, win, did_split)
          end
          return vim.schedule(_20_)
        else
          local function _21_()
            return vim.notify(("gitu exited with code " .. status), vim.log.levels.WARN)
          end
          return vim.schedule(_21_)
        end
      end
      return vim.fn.jobstart({"gitu"}, {term = true, on_exit = _18_})
    end
    job = with_editor_origin(win, buf, _17_)
    if (job <= 0) then
      vim.notify("failed to start gitu", vim.log.levels.ERROR)
      return delete_gitu_buffer(buf)
    else
      return vim.cmd("startinsert")
    end
  end
end
vim.api.nvim_create_user_command("Gitu", gitu, {})
local function _25_()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if gitu_buffer_3f(buf) then
      delete_gitu_buffer(buf)
    else
    end
  end
  return nil
end
return vim.api.nvim_create_user_command("GituClear", _25_, {})
