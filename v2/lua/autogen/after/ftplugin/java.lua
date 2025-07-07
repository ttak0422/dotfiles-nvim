-- [nfnl] v2/fnl/after/ftplugin/java.fnl
local jdk8_path = args.jdk8_path
local jdk11_path = args.jdk11_path
local jdk17_path = args.jdk17_path
local jdk21_path = args.jdk21_path
local jdk23_path = args.jdk23_path
local java_path = args.java_path
local jdtls_jar_pattern = args.jdtls_jar_pattern
local jdtls_config_path = args.jdtls_config_path
local java_debug_jar_pattern = args.java_debug_jar_pattern
local java_test_jar_pattern = args.java_test_jar_pattern
local lombok_jar_path = args.lombok_jar_path
local vscode_spring_boot_path = args.vscode_spring_boot_path
local jdtls = require("jdtls")
local jdtls_dap = require("jdtls.dap")
local spring_boot = require("spring_boot")
local root_dir = vim.fs.root(0, {"gradlew", "mvnw", ".git"})
local function setup()
  local workspace_dir = (os.getenv("HOME") .. "/.local/share/eclipse/" .. string.gsub(vim.fn.fnamemodify(root_dir, ":p:h"), "/", "_"))
  local dir_3f
  local function _1_(path)
    local tmp_3_ = vim.uv.fs_stat(path)
    if (nil ~= tmp_3_) then
      local tmp_3_0 = tmp_3_[type]
      if (nil ~= tmp_3_0) then
        return (tmp_3_0 == "directory")
      else
        return nil
      end
    else
      return nil
    end
  end
  dir_3f = _1_
  local cmd = {java_path, "-Declipse.application=org.eclipse.jdt.ls.core.id1", "-Dosgi.bundles.defaultStartLevel=4", "-Declipse.product=org.eclipse.jdt.ls.core.product", ("-Dosgi.sharedConfiguration.area=" .. jdtls_config_path), "-Dosgi.sharedConfiguration.area.readOnly=true", "-Dosgi.checkConfiguration=true", "-Dosgi.configuration.cascaded=true", "-Dlog.protocol=true", "-Dlog.level=ERROR", "-Xlog:disable", "-XX:+AlwaysPreTouch", "-Xmx10g", ("-javaagent:" .. lombok_jar_path), "--add-modules=ALL-SYSTEM", "--add-opens", "java.base/java.util=ALL-UNNAMED", "--add-opens", "java.base/java.lang=ALL-UNNAMED", "-jar", vim.fn.glob(jdtls_jar_pattern), "-data", workspace_dir}
  local settings
  do
    local enabled = {enabled = true}
    local disabled = {enabled = false}
    local favoriteStaticMembers = {"io.crate.testing.Asserts.assertThat", "java.util.Objects.requireNonNull", "java.util.Objects.requireNonNullElse", "org.assertj.core.api.Assertions.*", "org.assertj.core.api.Assertions.assertThat", "org.assertj.core.api.Assertions.assertThatExceptionOfType", "org.assertj.core.api.Assertions.assertThatThrownBy", "org.assertj.core.api.Assertions.catchThrowable", "org.hamcrest.CoreMatchers.*", "org.hamcrest.MatcherAssert.assertThat", "org.hamcrest.Matchers.*", "org.junit.jupiter.api.Assertions.*", "org.junit.jupiter.api.Assumptions.*", "org.junit.jupiter.api.DynamicContainer.*", "org.junit.jupiter.api.DynamicTest.*", "org.mockito.Answers.*", "org.mockito.ArgumentMatchers.*", "org.mockito.Mockito.*"}
    local filteredTypes = {"java.awt.*", "com.sun.*", "sun.*", "jdk.*", "io.micrometer.shaded.*", "javax.*"}
    local completion = {favoriteStaticMembers = favoriteStaticMembers, filteredTypes = filteredTypes}
    local edit = {smartSemicolonDetection = enabled, validateAllOpenBuffersOnChanges = false}
    local sources = {organizeImports = {starThreshold = 9999, staticStarThreshold = 9999}}
    local configuration = {runtimes = {{name = "JavaSE-1.8", path = jdk8_path}, {name = "JavaSE-11", path = jdk11_path}, {name = "JavaSE-17", path = jdk17_path}, {name = "JavaSE-21", path = jdk21_path}, {name = "JavaSE-23", path = jdk23_path}}}
    local java = {autobuild = disabled, maxConcurrentBuilds = 8, signatureHelp = enabled, format = disabled, configuration = configuration, completion = completion, edit = edit, sources = sources}
    settings = {java = java}
  end
  local bundles
  do
    local debug_jars = vim.split(vim.fn.glob(java_debug_jar_pattern, 1), "\n")
    local test_jars = vim.split(vim.fn.glob(java_test_jar_pattern, 1), "\n")
    local jar_filter
    local function _4_(_, v)
      return (("" ~= v) and not vim.endswith(v, "com.microsoft.java.test.runner-jar-with-dependencies.jar") and not vim.endswith(v, "jacocoagent.jar"))
    end
    jar_filter = _4_
    local function _5_(_, v)
      return v
    end
    bundles = vim.iter(ipairs(vim.list_extend(vim.list_extend(vim.list_extend({}, debug_jars), test_jars), spring_boot.java_extensions()))):filter(jar_filter):map(_5_):totable()
  end
  local extendedClientCapabilities = vim.tbl_deep_extend("force", jdtls.extendedClientCapabilities, {resolveAdditionalTextEditsSupport = true, progressReportProvider = false})
  local init_options = {bundles = bundles, extendedClientCapabilities = extendedClientCapabilities}
  local on_attach
  local function _6_(client, bufnr)
    local build_timeout = 10000
    local desc
    local function _7_(desc0)
      return {silent = true, buffer = bufnr, desc = desc0}
    end
    desc = _7_
    local with_compile
    local function _8_(f)
      local function _9_()
        if vim.bo.modified then
          vim.cmd("w")
        else
        end
        client.request_sync("java/buildWorkspace", false, build_timeout, bufnr)
        return f()
      end
      return _9_
    end
    with_compile = _8_
    jdtls_dap.setup_dap({hotcodereplace = "auto"})
    jdtls_dap.setup_dap_main_class_configs()
    for _, k in ipairs({{"<LocalLeader>Tt", with_compile(jdtls.test_nearest_method), desc("\238\153\173 test nearest")}, {"<LocalLeader>TT", with_compile(jdtls.test_class), desc("\238\153\173 test class")}}) do
      vim.keymap.set("n", k[1], k[2], k[3])
    end
    return nil
  end
  on_attach = _6_
  local flags = {allow_incremental_sync = true, debounce_text_changes = 300}
  local handlers
  local function _11_()
  end
  handlers = {["language/status"] = _11_}
  if not dir_3f(workspace_dir) then
    vim.uv.fs_mkdir(workspace_dir, 493)
  else
  end
  jdtls.start_or_attach({root_dir = root_dir, cmd = cmd, settings = settings, init_options = init_options, on_attach = on_attach, flags = flags, handlers = handlers})
  if not vim.g.spring_boot_initialized then
    vim.g.spring_boot_initialized = true
    return spring_boot.setup({ls_path = (vscode_spring_boot_path .. "/language-server"), server = {cmd = {java_path, "-jar", vim.fn.glob((vscode_spring_boot_path .. "/language-server/" .. "spring-boot-language-server-*.jar")), "-Dsts.lsp.client=vscode", "-Dlogging.level.org.springframework=OFF"}}})
  else
    return nil
  end
end
return setup()
