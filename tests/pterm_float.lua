-- nvim --headless -u NONE -i NONE -l tests/pterm_float.lua
-- Set PTERM_PLUGIN_ROOT and put a matching pterm binary on PATH.
vim.opt.runtimepath:prepend(assert(vim.env.TERMINAL_TEST_PTERM_PLUGIN or vim.env.PTERM_PLUGIN_ROOT))
vim.o.columns = 140
vim.o.lines = 44
local root = vim.fn.tempname()
local shell = vim.env.TERMINAL_TEST_CHILD or vim.fn.exepath("sh")
local pterm = require("pterm")
pterm.setup({ socket_dir = root .. "/sockets", auto_redraw = false, shell = shell })
vim.env.PTERM_SOCKET_DIR = root .. "/sockets"
vim.env.SHELL = shell
local actions = {}
package.loaded.toggler = { register = function(name, action) actions[name] = action end }
if vim.env.TERMINAL_TEST_NFNL then
  vim.opt.runtimepath:append(vim.env.TERMINAL_TEST_NFNL)
  local path = "v2/fnl/toggle-plugins.fnl"
  local compiled = "-- [nfnl] " .. path .. "\n" .. require("nfnl.fennel")["compile-string"](
    table.concat(vim.fn.readfile(path), "\n"), { filename = path })
  assert(compiled == table.concat(vim.fn.readfile("v2/lua/autogen/toggle-plugins.lua"), "\n"), "Fennel/Lua parity")
end
-- Loading the real generated configuration tests the Ctrl+1 registration path.
dofile("v2/lua/autogen/toggle-plugins.lua")
local session = "vim_tab" .. vim.api.nvim_get_current_tabpage() .. "_idx1"
local function size()
  local raw = pterm.dump(session)
  return raw and vim.json.decode(raw).screen.size
end
local function expect_size(tag)
  local win = vim.api.nvim_get_current_win()
  local width = vim.api.nvim_win_get_width(win) - vim.fn.getwininfo(win)[1].textoff
  local height = vim.api.nvim_win_get_height(win)
  assert(vim.wait(3000, function()
    local actual = size()
    return actual and actual.cols == width and actual.rows == height
  end, 20), tag .. ": active window did not own PTY dimensions")
end
local ok, err = xpcall(function()
  local origin = vim.api.nvim_get_current_win()
  actions.term1.open()
  local popup = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_get_current_buf()
  assert(vim.wait(3000, function() return size() ~= nil end, 20), "terminal daemon did not start")
  assert(pterm.is_connected(session), "Ctrl+1 bypassed the managed pterm plugin")
  expect_size("initial popup")
  actions.term1.close()
  assert(vim.api.nvim_buf_is_valid(buf), "closing float destroyed the session buffer")
  vim.api.nvim_set_current_win(origin)
  vim.api.nvim_win_set_buf(origin, buf)
  vim.cmd("vsplit")
  vim.cmd("vertical resize 35")
  local split = vim.api.nvim_get_current_win()
  expect_size("regular split")
  actions.term1.open()
  popup = vim.api.nvim_get_current_win()
  assert(vim.api.nvim_get_current_buf() == buf, "float opened a second bridge/buffer")
  expect_size("split to float")
  vim.o.columns = 150
  vim.api.nvim_exec_autocmds("VimResized", { modeline = false })
  assert(vim.api.nvim_win_get_width(popup) == math.floor(vim.o.columns * 0.95), "UI resize left a stale popup size")
  expect_size("UI resize")
  vim.api.nvim_win_set_width(split, 28)
  vim.api.nvim_exec_autocmds("WinResized", { modeline = false })
  expect_size("inactive split resize")
  vim.api.nvim_set_current_win(split)
  expect_size("float to split")
  vim.api.nvim_win_set_config(popup, { width = 105, height = 30 })
  vim.api.nvim_exec_autocmds("WinResized", { modeline = false })
  expect_size("inactive float resize")
  vim.api.nvim_set_current_win(popup)
  expect_size("float active again")
  actions.term1.close()
  expect_size("close active float fallback")
  assert(pterm.is_connected(session), "closing float disconnected managed bridge")
  if vim.env.TERMINAL_TEST_CHILD then
    local job = vim.bo[buf].channel
    vim.fn.chansend(job, "history\n")
    local expected = "HISTORY-00:" .. string.rep("abcdefghij", 12) .. "漢字界e\204\129:END"
    assert(vim.wait(3000, function() return (pterm.full_text(session) or ""):find(expected, 1, true) end, 20))
    local history_win = vim.api.nvim_open_win(buf, true, {
      relative = "editor", row = 1, col = 1, width = 80, height = 20, style = "minimal",
    })
    for _, width in ipairs({ 5, 80 }) do
      vim.api.nvim_win_set_config(history_win, { width = width })
      vim.api.nvim_exec_autocmds("WinResized", { modeline = false })
      expect_size("history width " .. width)
    end
    assert(vim.wait(3000, function()
      local canonical = pterm.full_text(session) or ""
      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      local native = table.concat(lines, "\n")
      local reflowed = false
      for _, line in ipairs(lines) do
        if line == expected:sub(1, 80) then reflowed = true end
      end
      return canonical:find(expected, 1, true) and canonical:find("HARD-A\nHARD-B", 1, true)
        and reflowed and native:gsub("\n", ""):find(expected, 1, true)
        and native:find("HARD-A\nHARD-B", 1, true)
    end, 20), "narrow history replay did not reflow to 80 columns with Unicode and genuine line breaks")
    vim.api.nvim_win_close(history_win, true)
  end
  actions.term1.open()
  expect_size("reopen float")
  actions.term1.close()
  pterm.detach(session)
  vim.wait(100)
  actions.term1.open()
  assert(pterm.is_connected(session), "reconnect lost the managed bridge")
  expect_size("managed reconnect")
  actions.term1.close()
end, debug.traceback)
if not ok then
  local current = vim.api.nvim_get_current_buf()
  print(vim.inspect({ windows = vim.fn.getwininfo(), native = vim.api.nvim_buf_get_lines(current, 0, -1, false), canonical = pterm.full_text(session) }))
end
pcall(pterm.kill, session)
vim.fn.delete(root, "rf")
if not ok then error(err) end
print("Managed Ctrl+1 split/float regressions passed")
