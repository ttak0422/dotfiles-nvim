-- [nfnl] Compiled from fnl/after/java.fnl by https://github.com/Olical/nfnl, do not edit.
local jdtls = setmetatable({setup = require("jdtls.setup"), dap = require("jdtls.dap")}, {__index = require("jdtls")})
local spring_boot = require("spring_boot")
local enabled = {enabled = true}
local disabled = {enabled = false}
local root_dir = jdtls.setup.find_root({".git", "mvnw", "gradlew"})
local extendedClientCapabilities
do
  local c = jdtls.extendedClientCapabilities
  c["resolveAdditionalTextEditsSupport"] = true
  extendedClientCapabilities = c
end
local debug_jars = vim.split(vim.fn.glob(args.java_debug_jar_pattern, 1), "\n")
local test_jars = vim.split(vim.fn.glob(args.java_test_jar_pattern, 1), "\n")
local bundles
do
  local tbl = {}
  for _, v in ipairs(debug_jars) do
    if ("" ~= v) then
      table.insert(tbl, v)
    else
    end
  end
  for _, v in ipairs(test_jars) do
    if (("" ~= v) and not vim.endswith(v, "com.microsoft.java.test.runner-jar-with-dependencies.jar") and not vim.endswith(v, "jacocoagent.jar")) then
      table.insert(tbl, v)
    else
    end
  end
  for _, v in ipairs(spring_boot.java_extensions()) do
    table.insert(tbl, v)
  end
  bundles = tbl
end
local init_options = {bundles = bundles, extendedClientCapabilities = extendedClientCapabilities}
local settings
do
  local autobuild = disabled
  local maxConcurrentBuilds = 8
  local saveActions = {organizeImports = false}
  local sources = {organizeImports = {starThreshold = 9999, staticStarThreshold = 9999}}
  local favoriteStaticMembers = {"org.junit.jupiter.api.Assertions.*", "org.junit.jupiter.api.Assumptions.*", "org.junit.jupiter.api.DynamicContainer.*", "org.junit.jupiter.api.DynamicTest.*", "org.assertj.core.api.Assertions.*", "org.mockito.Mockito.*", "org.mockito.ArgumentMatchers.*", "org.mockito.Answers.*", "org.mockito.Mockito.*"}
  local filteredTypes = {"java.awt.*", "com.sun.*", "sun.*", "jdk.*", "org.gaalvm.*", "io.micrometer.shaded.*"}
  local completion = {favoriteStaticMembers = favoriteStaticMembers, filteredTypes = filteredTypes}
  local edit = {smartSemicolonDetection = enabled, validateAllOpenBuffersOnChanges = false}
  local signatureHelp = {enabled = true, description = enabled}
  settings = {java = {autobuild = autobuild, maxConcurrentBuilds = maxConcurrentBuilds, signatureHelp = signatureHelp, saveActions = saveActions, edit = edit, completion = completion, sources = sources}}
end
local home = os.getenv("HOME")
local work_space = (home .. "/.local/share/eclipse/" .. vim.fn.fnamemodify(root_dir, ":p:h"):gsub("/", "_"))
local cmd = {args.java_path, "-Declipse.application=org.eclipse.jdt.ls.core.id1", "-Dosgi.bundles.defaultStartLevel=4", "-Declipse.product=org.eclipse.jdt.ls.core.product", ("-Dosgi.sharedConfiguration.area=" .. args.jdtls_config_path), "-Dosgi.sharedConfiguration.area.readOnly=true", "-Dosgi.checkConfiguration=true", "-Dosgi.configuration.c:ascaded=true", "-Dlog.protocol=true", "-Dlog.level=ERROR", "-Xlog:disable", "-Xms1G", "-Xmx12G", ("-javaagent:" .. args.lombok_jar_path), "-jar", vim.fn.glob(args.jdtls_jar_pattern), "-data", work_space}
local handlers
local function _3_()
end
handlers = {["language/status"] = _3_}
local build_timeout = 10000
local on_attach
local function _4_(client, bufnr)
  local opts
  local function _5_(desc)
    return {silent = true, buffer = bufnr, desc = desc}
  end
  opts = _5_
  local with_compile
  local function _6_(f)
    local function _7_()
      if vim.bo.modified then
        vim.cmd("w")
      else
      end
      client.request_sync("java/buildWorkspace", false, build_timeout, bufnr)
      return f()
    end
    return _7_
  end
  with_compile = _6_
  local N = {{"<LocalLeader>o", jdtls.organize_imports, opts("[JDTLS] organize imports")}}
  jdtls.dap.setup_dap({hotcodereplace = "auto"})
  jdtls.dap.setup_dap_main_class_configs()
  for _, k in ipairs(N) do
    vim.keymap.set("n", k[1], k[2], k[3])
  end
  return nil
end
on_attach = _4_
local config = {root_dir = root_dir, settings = settings, cmd = cmd, capabilities = capabilities, on_attach = on_attach, handlers = handlers, init_options = init_options}
vim.g.jdtjdt = bundles
return jdtls.start_or_attach(config)
