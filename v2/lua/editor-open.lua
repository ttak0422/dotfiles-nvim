-- editor-open.lua
-- 軽量エディタラッパー: 親Neovimにファイルを開かせる
-- Usage: nvim --headless --clean -l editor-open.lua [--wait] [--line=N file] ...
-- Note: +N は nvim -l に消費されるため、シェルラッパーが --line=N に変換する

local addr = os.getenv("NVIM_EDITOR_ADDR") or os.getenv("NVIM")
if not addr then
  os.exit(1)
end

-- 引数解析: --line=N は直後のファイルとペアにする
local wait = false
local pending_line = nil
local entries = {} -- { {file=..., line=...}, ... }
for i = 1, #arg do
  if arg[i] == "--wait" then
    wait = true
  elseif arg[i]:match("^--line=(%d+)$") then
    pending_line = "+" .. arg[i]:match("^--line=(%d+)$")
  else
    table.insert(entries, {
      file = vim.fn.fnamemodify(arg[i], ":p"),
      line = pending_line,
    })
    pending_line = nil
  end
end

if #entries == 0 then
  os.exit(0)
end

local ok, chan = pcall(vim.fn.sockconnect, "pipe", addr, { rpc = true })
if not ok or chan == 0 then
  os.exit(1)
end

-- 親Neovimでファイルを開く
local any_ok = false
local target = nil
for _, entry in ipairs(entries) do
  local rok, _
  if entry.line then
    -- nvim_cmd の edit は nargs=? のため +N を別引数にできない。
    -- nvim_exec2 で ":edit +N file" をそのまま実行する。
    local cmd_str = "edit " .. entry.line .. " " .. vim.fn.fnameescape(entry.file)
    rok, _ = pcall(vim.rpcrequest, chan, "nvim_exec2", cmd_str, {})
  else
    rok, _ = pcall(vim.rpcrequest, chan, "nvim_cmd", { cmd = "edit", args = { entry.file } }, {})
  end
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
  local buf_ok, bufnr = pcall(vim.rpcrequest, chan, "nvim_call_function", "bufnr", { target })
  if buf_ok and type(bufnr) == "number" and bufnr > 0 then
    local lock = vim.fn.tempname()
    vim.fn.writefile({}, lock)
    -- 親でバッファが閉じられたらロックファイルを消す
    local acmd_ok, _ = pcall(vim.rpcrequest, chan, "nvim_exec_lua", [[
      local bufnr, lockfile = ...
      vim.api.nvim_create_autocmd({'BufDelete', 'BufWipeout', 'BufHidden', 'BufUnload'}, {
        buffer = bufnr,
        once = true,
        callback = function() os.remove(lockfile) end,
      })
    ]], { bufnr, lock })
    -- autocmd設定失敗、またはバッファが既に消えている場合はロック解除
    if not acmd_ok then
      os.remove(lock)
    else
      local still_exists, exists = pcall(vim.rpcrequest, chan, "nvim_call_function", "bufexists", { bufnr })
      if still_exists and exists == 0 then
        os.remove(lock)
      end
    end
    -- ロックファイルが消えるまでブロック
    while vim.fn.filereadable(lock) == 1 do
      local alive = pcall(vim.rpcrequest, chan, "nvim_get_mode")
      if not alive then
        os.remove(lock)
        break
      end
      vim.uv.sleep(100)
    end
  end
end

vim.fn.chanclose(chan)
os.exit(0)