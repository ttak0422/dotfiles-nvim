-- [nfnl] v2/fnl/gitu.fnl
local function gitu()
  if (vim.system({"git", "rev-parse", "--abbrev-ref", "HEAD"}):wait().code ~= 0) then
    return vim.notify("not a git repository", vim.log.levels.WARN)
  else
    if (#vim.api.nvim_list_wins() == 1) then
      local w = vim.api.nvim_win_get_width(0)
      local h = (vim.api.nvim_win_get_height(0) * 2.1)
      if (h > w) then
        vim.cmd.split()
      else
        vim.cmd.vsplit()
      end
    else
    end
    vim.cmd.enew()
    vim.wo.number = false
    vim.wo.foldcolumn = "0"
    vim.wo.signcolumn = "no"
    local bufnr = vim.api.nvim_get_current_buf()
    local on_exit
    local function _3_()
      if (#vim.api.nvim_list_wins() ~= 1) then
        local buf = vim.fn.bufnr("#")
        if ((buf ~= -1) and vim.api.nvim_buf_is_valid(buf)) then
          return vim.api.nvim_win_set_buf(vim.api.nvim_get_current_win(), buf)
        else
          return nil
        end
      else
        if vim.api.nvim_buf_is_valid(bufnr) then
          return vim.api.nvim_buf_delete(bufnr, {force = true})
        else
          return nil
        end
      end
    end
    on_exit = _3_
    vim.fn.termopen("gitu", {on_exit = on_exit})
    vim.cmd.startinsert()
    vim.bo[bufnr]["bufhidden"] = "wipe"
    vim.bo[bufnr]["swapfile"] = false
    vim.bo[bufnr]["buflisted"] = false
    return vim.api.nvim_create_autocmd("BufLeave", {buffer = bufnr, once = true, callback = on_exit})
  end
end
return vim.api.nvim_create_user_command("Gitu", gitu, {})
