-- Uses the pinned nvim-jdtls and real Neovim client/buffer lifecycle. Only the
-- external language-server process is replaced with a small stdio fixture.
local temp = vim.fn.tempname()
local function check()
  for _, env in ipairs({ "JDTLS_PLUGIN_DIR", "NFNL_PLUGIN_DIR" }) do
    vim.opt.runtimepath:append(assert(vim.env[env], env .. " is required"))
  end
  vim.env.HOME = temp
  vim.fn.mkdir(temp .. "/.local/share/eclipse", "p")
  local path = "v2/fnl/after/ftplugin/java_mini.fnl"
  local compiled = "-- [nfnl] " .. path .. "\n"
    .. require("nfnl.fennel")["compile-string"](table.concat(vim.fn.readfile(path), "\n"), { filename = path })
  assert(compiled == table.concat(vim.fn.readfile("v2/lua/autogen/after/ftplugin/java_mini.lua"), "\n"),
    "generated Java Lua differs from Fennel")
  local attach = temp .. "/attach.lua"
  vim.fn.writefile({ "return function() end" }, attach)
  _G.args = {
    java_path = vim.fn.getcwd() .. "/tests/java-attach-server.py",
    jdtls_jar_pattern = "unused", jdtls_config_path = "unused", lombok_jar_path = "unused",
    jdk8_path = "unused", jdk11_path = "unused", jdk17_path = "unused", jdk21_path = "unused",
    attach_path = attach,
  }
  local function file(root, name)
    vim.fn.mkdir(root .. "/.git", "p")
    vim.fn.writefile({ "class " .. name .. " {}" }, root .. "/" .. name .. ".java")
    local buf = vim.fn.bufadd(root .. "/" .. name .. ".java")
    vim.fn.bufload(buf)
    vim.bo[buf].filetype = "java"
    return buf
  end
  local function start(buf)
    vim.api.nvim_set_current_buf(buf)
    dofile("v2/lua/autogen/after/ftplugin/java_mini.lua")
  end
  local function clients(buf)
    return vim.lsp.get_clients({ name = "jdtls", bufnr = buf })
  end
  temp = vim.uv.fs_realpath(temp)
  local aroot, broot = temp .. "/a", temp .. "/b"
  local a, b = file(aroot, "A"), file(broot, "B")
  start(a)
  start(b)
  assert(vim.wait(3000, function()
    return #vim.lsp.get_clients({ name = "jdtls" }) == 2
      and vim.iter(vim.lsp.get_clients({ name = "jdtls" })):all(function(c) return c.initialized end)
  end, 10), "fixture clients did not initialize")
  assert(#clients(a) == 1 and clients(a)[1].config.root_dir == aroot,
    "switching projects before the delay must attach project A to its original buffer")
  assert(#clients(b) == 1 and clients(b)[1].config.root_dir == broot,
    "project B must only receive its own client")
  assert(vim.api.nvim_get_current_buf() == b, "delayed attach changed the visible buffer")
  print("PASS: two projects switched within 100 ms attach to their original buffers")
  local deleted = file(temp .. "/deleted", "Deleted")
  start(deleted)
  vim.api.nvim_buf_delete(deleted, { force = true })
  vim.api.nvim_set_current_buf(b)
  vim.v.errmsg = ""
  vim.wait(200)
  assert(vim.v.errmsg == "", "deleting a pending buffer caused a deferred callback error: " .. vim.v.errmsg)
  assert(#vim.lsp.get_clients({ name = "jdtls" }) == 2, "deleted buffer started another client")
  print("PASS: deleting a pending buffer does not start a client or raise a callback error")
  local changes = {
    { "unloaded", function(buf) vim.api.nvim_buf_delete(buf, { unload = true }) end },
    { "non-Java", function(buf) vim.bo[buf].filetype = "markdown" end },
    { "non-file", function(buf) vim.bo[buf].buftype = "nofile" end },
    { "root removed", function(_, root) vim.fn.delete(root .. "/.git", "d") end },
    { "renamed into another project", function(buf) vim.api.nvim_buf_set_name(buf, broot .. "/Moved.java") end },
  }
  for index, case in ipairs(changes) do
    local root = temp .. "/change-" .. index
    local buf = file(root, "Pending")
    start(buf)
    case[2](buf, root)
    vim.api.nvim_set_current_buf(b)
    vim.v.errmsg = ""
    vim.wait(200)
    assert(vim.v.errmsg == "", case[1] .. ": " .. vim.v.errmsg)
    assert(#clients(buf) == 0 and #vim.lsp.get_clients({ name = "jdtls" }) == 2,
      case[1] .. ": stale callback attached a client")
  end
  for _, kind in ipairs({ "rootless", "unnamed", "non-file" }) do
    local buf = vim.api.nvim_create_buf(true, false)
    vim.bo[buf].filetype = "java"
    if kind ~= "unnamed" then
      vim.fn.mkdir(temp .. "/rootless", "p")
      vim.api.nvim_buf_set_name(buf, temp .. "/rootless/" .. kind .. ".java")
    end
    if kind == "non-file" then vim.bo[buf].buftype = "nofile" end
    start(buf)
    vim.api.nvim_set_current_buf(b)
    vim.wait(200)
    assert(#clients(buf) == 0 and #vim.lsp.get_clients({ name = "jdtls" }) == 2,
      kind .. ": ineligible buffer started a client")
  end
  local croot = temp .. "/c"
  local c = file(croot, "C")
  start(c)
  local scratch = vim.api.nvim_create_buf(false, true)
  vim.bo[scratch].filetype = "markdown"
  vim.api.nvim_set_current_buf(scratch)
  assert(vim.wait(3000, function() return #clients(c) == 1 and clients(c)[1].initialized end, 10))
  assert(clients(c)[1].config.root_dir == croot and #clients(scratch) == 0)
  assert(vim.api.nvim_get_current_buf() == scratch, "attach stole the visible buffer")
  print("PASS: unloaded/non-Java/non-file/rootless/renamed buffers, root removal, and scratch switching")
end
local ok, err = xpcall(check, debug.traceback)
for _, client in ipairs(vim.lsp.get_clients({ name = "jdtls" })) do client:stop(true) end
vim.wait(1000, function() return #vim.lsp.get_clients({ name = "jdtls" }) == 0 end, 10)
vim.fn.delete(temp, "rf")
if not ok then io.stderr:write(err .. "\n"); vim.cmd.cquit() end
