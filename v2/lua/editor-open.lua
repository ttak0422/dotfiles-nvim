-- editor-open.lua
-- 軽量エディタラッパー: 親Neovimにファイルを開かせる
-- Usage: nvim --headless --clean -l editor-open.lua [--wait] [--line=N file] ...
-- Note: +N は nvim -l に消費されるため、シェルラッパーが --line=N に変換する

local addr = os.getenv("NVIM_EDITOR_ADDR") or os.getenv("NVIM")
local origin_win = tonumber(os.getenv("NVIM_EDITOR_WIN") or "")
local origin_buf = tonumber(os.getenv("NVIM_EDITOR_BUF") or "")
if not addr then
  os.exit(1)
end

local function parse_args(args)
  local wait = false
  local pending_line = nil
  local entries = {}

  for i = 1, #args do
    if args[i] == "--wait" then
      wait = true
    elseif args[i]:match("^--line=(%d+)$") then
      pending_line = "+" .. args[i]:match("^--line=(%d+)$")
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
  if origin_buf then
    local ok, result = pcall(vim.rpcrequest, chan, "nvim_exec_lua", [[
      local bufnr = ...
      if not vim.api.nvim_buf_is_valid(bufnr) then
        return false
      end
      local wins = vim.fn.win_findbuf(bufnr)
      if #wins == 0 then
        return false
      end
      return vim.api.nvim_set_current_win(wins[1]) == nil
    ]], { origin_buf })
    if ok and result then
      return true
    end
  end

  if origin_win then
    local ok, result = pcall(vim.rpcrequest, chan, "nvim_call_function", "win_gotoid", { origin_win })
    return ok and result == 1
  end

  return false
end

local function open_entry(chan, entry)
  if entry.line then
    -- nvim_cmd の edit は nargs=? のため +N を別引数にできない。
    -- nvim_exec2 で ":edit +N file" をそのまま実行する。
    local cmd_str = "edit " .. entry.line .. " " .. vim.fn.fnameescape(entry.file)
    return pcall(vim.rpcrequest, chan, "nvim_exec2", cmd_str, {})
  end

  return pcall(vim.rpcrequest, chan, "nvim_cmd", { cmd = "edit", args = { entry.file } }, {})
end

local function wait_for_buffer(chan, target)
  local buf_ok, bufnr = pcall(vim.rpcrequest, chan, "nvim_call_function", "bufnr", { target })
  if not buf_ok or type(bufnr) ~= "number" or bufnr <= 0 then
    return
  end

  local lock = vim.fn.tempname()
  vim.fn.writefile({}, lock)

  local acmd_ok, _ = pcall(vim.rpcrequest, chan, "nvim_exec_lua", [[
    local bufnr, lockfile = ...
    vim.api.nvim_create_autocmd({'BufDelete', 'BufWipeout', 'BufHidden', 'BufUnload'}, {
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

  local still_exists, exists = pcall(vim.rpcrequest, chan, "nvim_call_function", "bufexists", { bufnr })
  if still_exists and exists == 0 then
    os.remove(lock)
  end

  while vim.fn.filereadable(lock) == 1 do
    local alive = pcall(vim.rpcrequest, chan, "nvim_get_mode")
    if not alive then
      os.remove(lock)
      break
    end
    vim.uv.sleep(100)
  end
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
local any_ok = false
local target = nil
for _, entry in ipairs(entries) do
  local rok, _ = open_entry(chan, entry)
  if rok then
    any_ok = true
    target = entry.file
  end
end

if not any_ok then
  vim.fn.chanclose(chan)
  os.exit(1)
end

if wait and target then
  wait_for_buffer(chan, target)
end

vim.fn.chanclose(chan)
os.exit(0)
