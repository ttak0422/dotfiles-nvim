-- [nfnl] v2/fnl/after/lsp/vtsls.fnl
local function _1_(err, result, ctx, config)
  local filtered
  if (not err and result and result.diagnostics) then
    local function _2_(d)
      return ((d.code ~= 80001) and (d.code ~= "80001"))
    end
    filtered = vim.tbl_extend("force", {}, result, {diagnostics = vim.tbl_filter(_2_, result.diagnostics)})
  else
    filtered = result
  end
  return vim.lsp.handlers["textDocument/publishDiagnostics"](err, filtered, ctx, config)
end
return {workspace_required = true, root_markers = {"tsconfig.json", "package.json", "jsconfig.json", ".node_project"}, handlers = {["textDocument/publishDiagnostics"] = _1_}, settings = {separate_diagnostic_server = true, publish_diagnostic_on = "insert_leave", typescript = {suggest = {completeFunctionCalls = true}, preferences = {importModuleSpecifier = "relative"}}}, flags = {debounce_text_changes = 1000}, vtsls = {experimental = {completion = {enableServerSideFuzzyMatch = true}}}, single_file_support = false}
