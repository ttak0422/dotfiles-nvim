-- [nfnl] Compiled from fnl/after/lsp/vtsls.fnl by https://github.com/Olical/nfnl, do not edit.
local climb = require("climbdir")
local marker = require("climbdir.marker")
local function _1_(path)
  return climb.climb(path, marker.one_of(marker.has_readable_file("package.json"), marker.has_directory("node_modules")), {halt = marker.one_of(marker.has_readable_file("deno.json"))})
end
return {settings = {separate_diagnostic_server = true, publish_diagnostic_on = "insert_leave", typescript = {suggest = {completeFunctionCalls = true}, preferences = {importModuleSpecifier = "relative"}}}, root_dir = _1_, flags = {debounce_text_changes = 1000}, vtsls = {experimental = {completion = {enableServerSideFuzzyMatch = true}}}, single_file_support = false}
