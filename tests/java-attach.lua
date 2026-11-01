-- Uses the pinned nvim-jdtls and real Neovim client/buffer lifecycle. Only the
-- external language-server process is replaced with a small stdio fixture.
local temp = vim.fn.tempname()
local started = {}
local function check()
  for _, env in ipairs({ "JDTLS_PLUGIN_DIR", "NFNL_PLUGIN_DIR" }) do
    vim.opt.runtimepath:append(assert(vim.env[env], env .. " is required"))
  end
  vim.env.HOME = temp
  vim.fn.mkdir(temp .. "/.local/share/eclipse", "p")
  temp = vim.uv.fs_realpath(temp)
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
  local function file(root, name, marker)
    vim.fn.mkdir(root .. "/src", "p")
    if marker == nil then
      vim.fn.mkdir(root .. "/.git", "p")
    elseif marker then
      vim.fn.writefile({}, root .. "/" .. marker)
    end
    vim.fn.writefile({ "class " .. name .. " {}" }, root .. "/src/" .. name .. ".java")
    local buf = vim.fn.bufadd(root .. "/src/" .. name .. ".java")
    vim.fn.bufload(buf)
    vim.bo[buf].filetype = "java"
    return buf
  end
  local startup = vim.fn.getcwd() .. "/v2/lua/autogen/after/ftplugin/java_mini.lua"
  local function start(buf)
    return vim.api.nvim_buf_call(buf, function()
      return dofile(startup)
    end)
  end
  local function clients(buf)
    return vim.lsp.get_clients({ name = "jdtls", bufnr = buf })
  end
  local function immediate(buf, root)
    local id = start(buf)
    assert(type(id) == "number", "Java startup must return a client ID without waiting for a timer")
    local client = assert(vim.lsp.get_client_by_id(id))
    started[id] = client
    assert(client.config.root_dir == root, "startup used the wrong project root")
    assert(client.attached_buffers[buf], "startup did not immediately target the Java buffer")
    return client
  end
  local function initialized()
    assert(vim.wait(3000, function()
      for _, client in pairs(started) do
        if not client.initialized then return false end
      end
      return true
    end, 10), "fixture clients did not initialize")
  end
  local aroot, broot = temp .. "/a", temp .. "/b"
  local a, b = file(aroot, "A"), file(broot, "B")
  vim.api.nvim_set_current_buf(a)
  local ac = immediate(a, aroot)
  vim.api.nvim_set_current_buf(b)
  immediate(b, broot)
  initialized()
  assert(#clients(a) == 1 and clients(a)[1].config.root_dir == aroot,
    "fast switching must attach project A to its original buffer")
  assert(#clients(b) == 1 and clients(b)[1].config.root_dir == broot,
    "project B must only receive its own client")
  assert(vim.api.nvim_get_current_buf() == b, "startup changed the visible buffer")
  assert(immediate(file(aroot, "A2"), aroot).id == ac.id, "same-project buffers must reuse their client")
  print("PASS: immediate startup, fast project switching, and same-project client reuse")

  for _, marker in ipairs({ "gradlew", "mvnw" }) do
    local root = temp .. "/project-" .. marker
    local buf = file(root, "Project", marker)
    immediate(buf, root)
    assert(vim.api.nvim_get_current_buf() == b, "starting a hidden Java buffer changed focus")
  end
  initialized()
  assert(vim.api.nvim_get_current_buf() == b, "initialization changed focus")
  print("PASS: Git/Gradle/Maven roots and hidden-buffer focus preservation")

  for _, kind in ipairs({ "non-Java", "non-file", "unnamed", "virtual" }) do
    local buf = file(temp .. "/ineligible-" .. kind, "Skipped")
    if kind == "non-Java" then vim.bo[buf].filetype = "markdown" end
    if kind == "non-file" then vim.bo[buf].buftype = "nofile" end
    if kind == "unnamed" then vim.api.nvim_buf_set_name(buf, "") end
    if kind == "virtual" then vim.api.nvim_buf_set_name(buf, "jdt://contents/Skipped.java") end
    local count = #vim.lsp.get_clients({ name = "jdtls" })
    assert(start(buf) == nil, kind .. ": ineligible buffer returned a client")
    assert(#clients(buf) == 0 and #vim.lsp.get_clients({ name = "jdtls" }) == count,
      kind .. ": ineligible buffer started a client")
  end
  print("PASS: non-Java, non-file, unnamed, and virtual buffers are skipped")

  local cwd = vim.fn.getcwd()
  vim.fn.mkdir(temp .. "/standalone-cwd", "p")
  vim.cmd.cd(temp .. "/standalone-cwd")
  immediate(file(temp .. "/standalone", "Standalone", false), vim.fn.getcwd())
  vim.cmd.cd(cwd)
  initialized()
  print("PASS: standalone Java retains the working-directory fallback")

  for _, unload in ipairs({ false, true }) do
    local root = temp .. "/" .. (unload and "unloaded" or "deleted")
    local buf = file(root, "Closed")
    local client = immediate(buf, root)
    assert(not client.initialized, "test must close the buffer before initialization")
    vim.api.nvim_buf_delete(buf, { force = true, unload = unload })
    vim.v.errmsg = ""
    initialized()
    assert(vim.v.errmsg == "", "closing a Java buffer during initialization caused an error: " .. vim.v.errmsg)
    assert(not client.attached_buffers[buf], "closed buffer remained attached")
    assert(vim.api.nvim_get_current_buf() == b, "closing a hidden buffer changed focus")
  end
  local croot = temp .. "/c"
  local c = file(croot, "C")
  vim.api.nvim_set_current_buf(c)
  immediate(c, croot)
  local scratch = vim.api.nvim_create_buf(false, true)
  vim.bo[scratch].filetype = "markdown"
  vim.api.nvim_set_current_buf(scratch)
  initialized()
  assert(#clients(c) == 1 and clients(c)[1].config.root_dir == croot and #clients(scratch) == 0)
  assert(vim.api.nvim_get_current_buf() == scratch, "initialization stole the visible buffer")
  print("PASS: buffer deletion/unload during initialization and immediate Markdown switching")
end
local ok, err = xpcall(check, debug.traceback)
for _, client in pairs(started) do client:stop(true) end
vim.wait(1000, function() return #vim.lsp.get_clients({ name = "jdtls" }) == 0 end, 10)
vim.fn.delete(temp, "rf")
if not ok then io.stderr:write(err .. "\n"); vim.cmd.cquit() end
