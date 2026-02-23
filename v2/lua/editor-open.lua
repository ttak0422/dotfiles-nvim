-- editor-open.lua
-- 軽量エディタラッパー: 親Neovimにファイルを開かせる
-- Usage: nvim --headless --clean -l editor-open.lua [--wait] [--line=N] file1 [file2 ...]
-- Note: +N は nvim -l に消費されるため、シェルラッパーが --line=N に変換する

local addr = os.getenv("NVIM_EDITOR_ADDR") or os.getenv("NVIM")
if not addr then
  os.exit(1)
end

local wait = false
local line_arg = nil
local files = {}
for i = 1, #arg do
  if arg[i] == "--wait" then
    wait = true
  elseif arg[i]:match("^--line=(%d+)$") then
    line_arg = "+" .. arg[i]:match("^--line=(%d+)$")
  else
    table.insert(files, vim.fn.fnamemodify(arg[i], ":p"))
  end
end

if #files == 0 then
  os.exit(0)
end

local ok, chan = pcall(vim.fn.sockconnect, "pipe", addr, { rpc = true })
if not ok or chan == 0 then
  os.exit(1)
end

-- 親Neovimでファイルを開く
local target = nil
for idx, f in ipairs(files) do
  local args = {}
  if idx == 1 and line_arg then
    table.insert(args, line_arg)
  end
  table.insert(args, f)
  pcall(vim.rpcrequest, chan, "nvim_cmd", { cmd = "edit", args = args }, {})
  target = f
end

if wait then
  -- 開いた対象ファイルのバッファを待つ（current buffer依存を避ける）
  local buf_ok, bufnr = pcall(vim.rpcrequest, chan, "nvim_call_function", "bufnr", { target })
  if buf_ok and type(bufnr) == "number" and bufnr > 0 then
    local lock = vim.fn.tempname()
    vim.fn.writefile({}, lock)
    -- 親でバッファ削除時にロックファイルを消すautocmdを設定
    pcall(vim.rpcrequest, chan, "nvim_exec_lua", [[
      local bufnr, lockfile = ...
      vim.api.nvim_create_autocmd({'BufDelete', 'BufWipeout'}, {
        buffer = bufnr,
        once = true,
        callback = function() os.remove(lockfile) end,
      })
    ]], { bufnr, lock })
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
