-- Run from the repository root:
-- nvim --headless -u NONE -i NONE -l tests/gitu-pterm.lua /path/to/pterm /path/to/better-escape
-- Use pterm's real Lua lifecycle with a fixture bridge instead of a daemon.
vim.opt.runtimepath:prepend(assert(arg[1]))
vim.opt.runtimepath:prepend(assert(arg[2]))

local function config(name)
  local path = "v3/packages/configurations/" .. name .. ".nix"
  local source = table.concat(vim.fn.readfile(path), "\n")
  local code = assert(source:match("config = luaConfig %(%s*# lua%s*''\n(.-)\n    ''"), path)
  assert(loadstring(code, "@" .. path))()
end

local root = vim.fn.tempname()
vim.fn.mkdir(root, "p")
local cwd = vim.fn.getcwd()
local function git(at, ...)
  local result = vim.system(vim.list_extend({ "git", "-C", at }, { ... }), { text = true }):wait()
  assert(result.code == 0, result.stderr)
end

local pterm = require("pterm")
-- The sandbox disallows server sockets; verify what would be inherited instead.
vim.v = setmetatable({ servername = root .. "/editor" }, { __index = vim.v })
local launch, stops, live = {}, {}, { ["unrelated"] = true }
local original_jobstart, original_executable = vim.fn.jobstart, vim.fn.executable
vim.fn.executable = function(bin)
  return bin == "pterm" and 1 or original_executable(bin)
end
vim.fn.jobstart = function(argv, opts)
  if argv[1] ~= "pterm" then
    return original_jobstart(argv, opts)
  end
  if argv[2] ~= "open" then
    return original_jobstart({ "true" }, opts)
  end
  assert(argv[#argv - 1] == "--" and argv[#argv] == "gitu", vim.inspect(argv))
  local job = original_jobstart({ "cat" }, opts)
  local buf = vim.api.nvim_get_current_buf()
  live[argv[3]] = true
  table.insert(launch, {
    name = argv[3],
    addr = vim.env.NVIM_EDITOR_ADDR,
    win = vim.env.NVIM_EDITOR_WIN,
    use_origin = vim.env.NVIM_EDITOR_USE_ORIGIN,
    editor = vim.env.GIT_EDITOR,
    job = job,
    buf = buf,
  })
  return job
end
local detach = pterm.detach
pterm.detach = function(name)
  table.insert(stops, name)
  detach(name)
end
pterm.list = function() return vim.tbl_keys(live) end
pterm.kill = function(name)
  assert(live[name], "unexpected kill")
  live[name] = nil
  pterm.detach(name)
end
pterm.setup({ socket_dir = root .. "/sockets", auto_redraw = false })
config("better-escape-nvim")
config("editor-gitu")

local function assert_bypass()
  local maps = {}
  for _, mapping in ipairs(vim.api.nvim_get_keymap("t")) do
    maps[mapping.lhs] = mapping.callback
  end
  local original = vim.api.nvim_feedkeys
  local count = 0
  vim.api.nvim_feedkeys = function()
    count = count + 1
  end
  assert(maps.j() == "j" and maps.k() == "k" and count == 0)
  vim.api.nvim_feedkeys = original
end

local function check()
  local a, b = root .. "/main repo", root .. "/linked repo"
  vim.fn.mkdir(a .. "/sub", "p")
  git(a, "init")
  git(a, "-c", "user.name=Fixture", "-c", "user.email=fixture@example.invalid",
    "-c", "commit.gpgsign=false", "commit", "--allow-empty", "-m", "fixture")
  git(a, "worktree", "add", "--detach", b)
  vim.env.NVIM_EDITOR_ADDR = "previous-address"
  vim.env.NVIM_EDITOR_WIN = "previous-win"
  vim.env.NVIM_EDITOR_BUF = "previous-buf"
  vim.env.NVIM_EDITOR_USE_ORIGIN = "previous-use-origin"
  vim.env.GIT_EDITOR = "original-git-editor"
  vim.cmd.cd(vim.fn.fnameescape(a .. "/sub"))
  vim.cmd.Gitu()
  local first = assert(launch[1])
  local first_win = vim.api.nvim_get_current_win()
  assert(first.name:match("^gitu%-%x+$") and #first.name == 29)
  assert(first.addr == vim.v.servername and first.win == tostring(first_win) and first.use_origin == "1")
  assert(first.editor == "original-git-editor" and vim.env.GIT_EDITOR == first.editor)
  assert(vim.env.NVIM_EDITOR_ADDR == "previous-address" and vim.env.NVIM_EDITOR_WIN == "previous-win")
  assert(vim.env.NVIM_EDITOR_BUF == "previous-buf" and vim.env.NVIM_EDITOR_USE_ORIGIN == "previous-use-origin")
  assert(not pterm.buffer_context(first.buf), "fixture unexpectedly has a foreground sample")
  assert_bypass()
  vim.cmd.wincmd("p")
  vim.cmd.cd(vim.fn.fnameescape(a))
  vim.cmd.Gitu()
  assert(#launch == 1 and vim.api.nvim_get_current_win() == first_win, "subdir did not reuse existing view")
  vim.cmd.wincmd("p")
  vim.cmd.cd(vim.fn.fnameescape(b))
  vim.cmd.Gitu()
  local second = assert(launch[2], "linked worktree did not get its own session")
  assert(second.name ~= first.name)
  vim.api.nvim_set_current_win(first_win)
  assert(vim.api.nvim_win_get_buf(first_win) == first.buf)
  live[first.name] = nil
  vim.fn.chansend(first.job, "\004") -- EOF on the fixture's canonical PTY.
  assert(vim.wait(2000, function() return not pterm.is_connected(first.name) end),
    "direct child exit did not release pterm view")
  assert(not vim.api.nvim_win_is_valid(first_win), "owned split was not closed on exit")
  live[second.name .. "/shared-child"] = true
  vim.cmd.GituClear()
  assert(vim.deep_equal(stops, {}) and pterm.is_connected(second.name))
  assert(live.unrelated and live[second.name .. "/shared-child"])
  live[second.name .. "/shared-child"] = nil
  pterm.detach(second.name)
  stops = {}
  vim.cmd.GituClear()
  assert(vim.deep_equal(stops, { second.name }), vim.inspect(stops))
  assert(live.unrelated and not live[second.name] and not pterm.is_connected(second.name))
  vim.cmd.cd(vim.fn.fnameescape(cwd))
end

local ok, err = pcall(check)
for _, item in ipairs(launch) do
  pcall(vim.fn.jobstop, item.job)
end
vim.fn.delete(root, "rf")
assert(ok, err)
print("Gitu pterm launch, worktree reuse, editor environment, keys and owned cleanup verified")
