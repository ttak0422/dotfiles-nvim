-- [nfnl] v2/fnl/after/ftplugin/gitcommit.fnl
vim.opt_local.iskeyword:append("-")
vim.bo.bufhidden = "wipe"
local function prefill_ticket()
  local buf = vim.api.nvim_get_current_buf()
  local name = vim.api.nvim_buf_get_name(buf)
  local file = vim.uv.fs_realpath(name)
  if ((vim.bo.filetype == "gitcommit") and file and (vim.fs.basename(file) == "COMMIT_EDITMSG") and not vim.b.ticket_prefix_checked and not vim.bo.modified and vim.bo.modifiable and not vim.bo.readonly) then
    vim.b.ticket_prefix_checked = true
    local gitdir = vim.fs.dirname(file)
    local tick = vim.api.nvim_buf_get_changedtick(buf)
    local env = vim.fn.environ()
    for _, key in ipairs({"GIT_DIR", "GIT_WORK_TREE", "GIT_COMMON_DIR", "GIT_NAMESPACE"}) do
      env[key] = nil
    end
    local function git(...)
      local argv = {"git", ("--git-dir=" .. gitdir)}
      local _ = vim.list_extend(argv, {...})
      local ok, result
      local function _1_()
        return vim.system(argv, {text = true, clear_env = true, env = env}):wait(300)
      end
      ok, result = pcall(_1_)
      if ok then
        return result
      else
        return nil
      end
    end
    local function operation_3f()
      local active = false
      for _, path in ipairs({"MERGE_HEAD", "SQUASH_MSG", "CHERRY_PICK_HEAD", "REVERT_HEAD", "rebase-merge", "rebase-apply", "sequencer"}) do
        if vim.uv.fs_stat((gitdir .. "/" .. path)) then
          active = true
        else
        end
      end
      return active
    end
    if not operation_3f() then
      local branch = git("symbolic-ref", "--quiet", "--short", "HEAD")
      local segment = (branch and (branch.code == 0) and branch.stdout:match("([^/\n]+)\n$"))
      local ticket = (segment and segment:match("^([A-Z][A-Z0-9]*%-%d+)_[A-Za-z0-9][A-Za-z0-9_-]*$"))
      if ticket then
        local comment_prefix = nil
        do
          local comment_config = git("config", "--null", "--get-regexp", "^core\\.comment(char|string)$")
          if comment_config then
            if (comment_config.code == 1) then
              comment_prefix = "#"
            elseif (comment_config.code == 0) then
              for entry in comment_config.stdout:gmatch("([^%z]*)%z") do
                comment_prefix = entry:match("^[^\n]+\n(.*)$")
              end
            else
            end
          else
          end
        end
        if (comment_prefix and (comment_prefix ~= "") and (comment_prefix ~= "auto") and vim.api.nvim_buf_is_valid(buf) and (vim.api.nvim_get_current_buf() == buf) and (vim.api.nvim_buf_get_name(buf) == name) and (vim.api.nvim_buf_get_changedtick(buf) == tick) and (vim.bo.filetype == "gitcommit") and not vim.bo.modified and vim.bo.modifiable and not vim.bo.readonly and not operation_3f()) then
          local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
          local prefix = (ticket .. " ")
          local empty = true
          for _, line in ipairs(lines) do
            if (not line:match("^%s*$") and (line:sub(1, #comment_prefix) ~= comment_prefix)) then
              empty = false
            else
            end
          end
          if empty then
            local _7_
            if string.match(lines[1], "^%s*$") then
              _7_ = 1
            else
              _7_ = 0
            end
            vim.api.nvim_buf_set_lines(buf, 0, _7_, false, {prefix})
            return vim.api.nvim_win_set_cursor(0, {1, #ticket})
          else
            return nil
          end
        else
          return nil
        end
      else
        return nil
      end
    else
      return nil
    end
  else
    return nil
  end
end
return vim.api.nvim_create_autocmd("BufWinEnter", {buffer = vim.api.nvim_get_current_buf(), once = true, callback = prefill_ticket})
