-- editor-open.lua
-- 軽量エディタラッパー: 親Neovimにファイルを開かせる
-- Usage: nvim --headless --clean -l editor-open.lua [--wait] [--line=N file] ...
-- Note: +N は nvim -l に消費されるため、シェルラッパーが --line=N に変換する

local addr = os.getenv("NVIM_EDITOR_ADDR") or os.getenv("NVIM")
local use_origin = os.getenv("NVIM_EDITOR_USE_ORIGIN") == "1"
local origin_win = use_origin and tonumber(os.getenv("NVIM_EDITOR_WIN") or "") or nil
local origin_buf = use_origin and tonumber(os.getenv("NVIM_EDITOR_BUF") or "") or nil
if not addr then
  os.exit(1)
end

local function request(chan, method, ...)
  return pcall(vim.rpcrequest, chan, method, ...)
end

local function parse_args(args)
  local wait = false
  local pending_line = nil
  local entries = {}

  for i = 1, #args do
    if args[i] == "--wait" then
      wait = true
    elseif args[i] == "--" then
      pending_line = nil
    elseif args[i]:match("^--line=(%d+)$") then
      pending_line = tonumber(args[i]:match("^--line=(%d+)$"))
    else
      table.insert(entries, {
        file = vim.fn.fnamemodify(args[i], ":p"),
        line = pending_line,
      })
      pending_line = nil
    end
  end

  return wait, entries
end

local function focus_origin(chan)
  local ok, result = request(chan, "nvim_exec_lua", [[
      local origin_win, bufnr = ...

      local function current_tab_wins()
        local wins = {}
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          wins[win] = true
        end
        return wins
      end

      local wins_in_tab = current_tab_wins()

      if type(origin_win) == "number"
          and wins_in_tab[origin_win]
          and vim.api.nvim_win_is_valid(origin_win) then
        vim.api.nvim_set_current_win(origin_win)
        return true
      end

      if type(bufnr) ~= "number" or not vim.api.nvim_buf_is_valid(bufnr) then
        return false
      end

      local wins = vim.fn.win_findbuf(bufnr)
      for _, win in ipairs(wins) do
        if wins_in_tab[win] and vim.api.nvim_win_is_valid(win) then
          vim.api.nvim_set_current_win(win)
          return true
        end
      end
      return false
    ]], { origin_win, origin_buf })
  if ok and result then
    return true
  end

  return false
end

local function open_entry(chan, entry, wait)
  return request(chan, "nvim_exec_lua", [[
    local file, line, origin_win, wait = ...
    local target = vim.fn.fnamemodify(file, ":p")
    local resolved_target = vim.fn.resolve(target)

    local function win_in_current_tab(win)
      for _, current_tab_win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if current_tab_win == win then
          return true
        end
      end
      return false
    end

    local function is_normal_win(win)
      return type(win) == "number"
        and vim.api.nvim_win_is_valid(win)
        and win_in_current_tab(win)
        and vim.api.nvim_win_get_config(win).relative == ""
    end

    local function is_pinned(win)
      local ok, value = pcall(vim.api.nvim_win_get_var, win, "sticky_original_bufnr")
      return ok and value ~= nil
    end

    local function is_candidate(win)
      if not is_normal_win(win) or is_pinned(win) then
        return false
      end

      local buf = vim.api.nvim_win_get_buf(win)
      local buftype = vim.bo[buf].buftype
      if buftype == "terminal" or buftype == "prompt" or buftype == "quickfix" or buftype == "nofile" then
        return false
      end

      return true
    end

    local function normal_wins()
      local wins = {}
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if is_normal_win(win) then
          table.insert(wins, win)
        end
      end
      return wins
    end

    local function split_from(win)
      if is_normal_win(win) then
        vim.api.nvim_set_current_win(win)
      else
        local wins = normal_wins()
        if #wins > 0 then
          vim.api.nvim_set_current_win(wins[1])
        end
      end

      if vim.o.columns / vim.o.lines > 2.5 then
        vim.cmd("vsplit")
      else
        vim.cmd("split")
      end
    end

    local function select_window()
      if not wait and type(origin_win) == "number"
          and vim.api.nvim_win_is_valid(origin_win)
          and win_in_current_tab(origin_win) then
        vim.api.nvim_set_current_win(origin_win)
        return
      end

      local wins = normal_wins()
      if #wins == 1 then
        split_from(wins[1])
        return
      end

      if is_candidate(origin_win) then
        vim.api.nvim_set_current_win(origin_win)
        return
      end

      for _, win in ipairs(wins) do
        if win ~= origin_win and is_candidate(win) then
          vim.api.nvim_set_current_win(win)
          return
        end
      end

      split_from(wins[1] or origin_win)
    end

    select_window()
    pcall(vim.cmd, "edit " .. vim.fn.fnameescape(target))

    local current = vim.fn.resolve(vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":p"))
    if current ~= resolved_target then
      return false
    end

    if line then
      local last = vim.api.nvim_buf_line_count(0)
      local lnum = math.max(1, math.min(line, last))
      pcall(vim.api.nvim_win_set_cursor, 0, { lnum, 0 })
    end

    return true
  ]], { entry.file, entry.line, origin_win, wait })
end

local function wait_for_buffer(chan, target)
  local buf_ok, bufnr = request(chan, "nvim_call_function", "bufnr", { target })
  if not buf_ok or type(bufnr) ~= "number" or bufnr <= 0 then
    return
  end

  local lock = vim.fn.tempname()
  vim.fn.writefile({}, lock)

  local acmd_ok, _ = request(chan, "nvim_exec_lua", [[
    local bufnr, lockfile = ...
    vim.api.nvim_create_autocmd({'BufDelete', 'BufWipeout', 'BufUnload'}, {
      buffer = bufnr,
      once = true,
      callback = function()
        os.remove(lockfile)
      end,
    })
  ]], { bufnr, lock })

  if not acmd_ok then
    os.remove(lock)
    return
  end

  local still_exists, exists = request(chan, "nvim_call_function", "bufexists", { bufnr })
  if still_exists and exists == 0 then
    os.remove(lock)
  end

  while vim.fn.filereadable(lock) == 1 do
    local alive = request(chan, "nvim_get_mode")
    if not alive then
      os.remove(lock)
      break
    end
    vim.uv.sleep(100)
  end
end

local function open_entries(chan, entries, wait)
  local any_ok = false
  local last_opened = nil

  for _, entry in ipairs(entries) do
    local ok, opened = open_entry(chan, entry, wait)
    if ok and opened then
      any_ok = true
      last_opened = entry.file
    end
  end

  return any_ok, last_opened
end

local wait, entries = parse_args(arg)

if #entries == 0 then
  os.exit(0)
end

local ok, chan = pcall(vim.fn.sockconnect, "pipe", addr, { rpc = true })
if not ok or chan == 0 then
  os.exit(1)
end

focus_origin(chan)

-- 親Neovimでファイルを開く
local any_ok, target = open_entries(chan, entries, wait)

if not any_ok then
  vim.fn.chanclose(chan)
  os.exit(1)
end

if wait and target then
  wait_for_buffer(chan, target)
end

vim.fn.chanclose(chan)
os.exit(0)
