-- [nfnl] v2/fnl/after/ftplugin/java_mini.fnl
local jdk8_path = args.jdk8_path
local jdk11_path = args.jdk11_path
local jdk17_path = args.jdk17_path
local jdk21_path = args.jdk21_path
local java_path = args.java_path
local jdtls_jar_pattern = args.jdtls_jar_pattern
local jdtls_config_path = args.jdtls_config_path
local lombok_jar_path = args.lombok_jar_path
local attach_path = args.attach_path
local jdtls = require("jdtls")
local bufnr = vim.api.nvim_get_current_buf()
local function java_buffer_3f()
  return (vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_is_loaded(bufnr) and (vim.bo[bufnr].buftype == "") and (vim.bo[bufnr].filetype == "java") and (vim.api.nvim_buf_get_name(bufnr) ~= "") and vim.startswith(vim.uri_from_bufnr(bufnr), "file://"))
end
local root_markers = {"gradlew", "mvnw", ".git"}
local root_dir
if java_buffer_3f() then
  root_dir = vim.fs.root(bufnr, root_markers)
else
  root_dir = nil
end
if not root_dir then
  return
else
end
local workspace_dir = (os.getenv("HOME") .. "/.local/share/eclipse/" .. string.gsub(vim.fn.fnamemodify(root_dir, ":p:h"), "/", "_"))
local _3_
do
  local tmp_3_ = vim.uv.fs_stat(workspace_dir)
  if (nil ~= tmp_3_) then
    local tmp_3_0 = tmp_3_[type]
    if (nil ~= tmp_3_0) then
      _3_ = (tmp_3_0 == "directory")
    else
      _3_ = nil
    end
  else
    _3_ = nil
  end
end
if not _3_ then
  vim.uv.fs_mkdir(workspace_dir, 493)
else
end
local cmd = {java_path, "-Declipse.application=org.eclipse.jdt.ls.core.id1", "-Dosgi.bundles.defaultStartLevel=4", "-Declipse.product=org.eclipse.jdt.ls.core.product", ("-Dosgi.sharedConfiguration.area=" .. jdtls_config_path), "-Dosgi.sharedConfiguration.area.readOnly=true", "-Dosgi.checkConfiguration=true", "-Dosgi.configuration.cascaded=true", "-Dlog.protocol=true", "-Dlog.level=ERROR", "-Xlog:disable", "-XX:+AlwaysPreTouch", "-Xmx10g", ("-javaagent:" .. lombok_jar_path), "--add-modules=ALL-SYSTEM", "--add-opens", "java.base/java.util=ALL-UNNAMED", "--add-opens", "java.base/java.lang=ALL-UNNAMED", "-jar", vim.fn.glob(jdtls_jar_pattern), "-data", workspace_dir}
local settings
do
  local enabled = {enabled = true}
  local disabled = {enabled = false}
  local favoriteStaticMembers = {"io.crate.testing.Asserts.assertThat", "java.util.Objects.requireNonNull", "java.util.Objects.requireNonNullElse", "org.assertj.core.api.Assertions.*", "org.assertj.core.api.Assertions.assertThat", "org.assertj.core.api.Assertions.assertThatExceptionOfType", "org.assertj.core.api.Assertions.assertThatThrownBy", "org.assertj.core.api.Assertions.catchThrowable", "org.hamcrest.CoreMatchers.*", "org.hamcrest.MatcherAssert.assertThat", "org.hamcrest.Matchers.*", "org.junit.jupiter.api.Assertions.*", "org.junit.jupiter.api.Assumptions.*", "org.junit.jupiter.api.DynamicContainer.*", "org.junit.jupiter.api.DynamicTest.*", "org.mockito.Answers.*", "org.mockito.ArgumentMatchers.*", "org.mockito.Mockito.*"}
  local filteredTypes = {"java.awt.*", "com.sun.*", "sun.*", "jdk.*", "io.micrometer.shaded.*"}
  local completion = {favoriteStaticMembers = favoriteStaticMembers, filteredTypes = filteredTypes}
  local edit = {smartSemicolonDetection = enabled, validateAllOpenBuffersOnChanges = false}
  local sources = {organizeImports = {starThreshold = 9999, staticStarThreshold = 9999}}
  local configuration = {runtimes = {{name = "JavaSE-1.8", path = jdk8_path}, {name = "JavaSE-11", path = jdk11_path}, {name = "JavaSE-17", path = jdk17_path}, {name = "JavaSE-21", path = jdk21_path, default = true}}}
  local java = {autobuild = disabled, maxConcurrentBuilds = 8, signatureHelp = enabled, format = disabled, configuration = configuration, completion = completion, edit = edit, sources = sources, referencesCodeLens = {enabled = true}, implementationsCodeLens = {enabled = true}, inlayHints = {parameterNames = {enabled = "all"}}}
  settings = {java = java}
end
local bundles = {}
local extendedClientCapabilities = vim.tbl_deep_extend("force", jdtls.extendedClientCapabilities, {resolveAdditionalTextEditsSupport = true, progressReportProvider = false})
local init_options = {bundles = bundles, extendedClientCapabilities = extendedClientCapabilities}
local on_attach
local function _8_(client, bufnr0)
  return dofile(attach_path)({buf = bufnr0, client = client})
end
on_attach = _8_
local flags = {allow_incremental_sync = true, debounce_text_changes = 300}
local handlers
local function _9_()
end
handlers = {["language/status"] = _9_}
local function _10_()
  if (java_buffer_3f() and (root_dir == vim.fs.root(bufnr, root_markers))) then
    local function _11_()
      return jdtls.start_or_attach({name = "jdtls", root_dir = root_dir, cmd = cmd, settings = settings, init_options = init_options, on_attach = on_attach, flags = flags, handlers = handlers})
    end
    return vim.api.nvim_buf_call(bufnr, _11_)
  else
    return nil
  end
end
return vim.defer_fn(_10_, 100)
