-- [nfnl] Compiled from fnl/after/lsp/denols.fnl by https://github.com/Olical/nfnl, do not edit.
local climb = require("climbdir")
local marker = require("climbdir.marker")
local function _1_(path)
  return climb.climb(path, marker.one_of(marker.has_readable_file("deno.json"), marker.has_readable_file("deno.jsonc"), marker.has_directory("denops")), {halt = marker.one_of(marker.has_readable_file("package.json"), marker.has_directory("node_modules"))})
end
return {root_dir = _1_, init_options = {lint = true, suggest = {completeFunctionCalls = true, names = true, paths = true, autoImports = true, imports = {autoDiscover = true, hosts = vim.empty_dict()}}, unstable = false}, settings = {deno = {enable = true}}, single_file_support = false}
