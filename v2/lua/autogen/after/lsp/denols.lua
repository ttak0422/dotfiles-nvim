-- [nfnl] v2/fnl/after/lsp/denols.fnl
return {workspace_required = true, root_markers = {"deno.json", "deno.jsonc", ".deno_project"}, init_options = {lint = true, suggest = {completeFunctionCalls = true, names = true, paths = true, autoImports = true, imports = {autoDiscover = true, hosts = vim.empty_dict()}}, unstable = false}, settings = {deno = {enable = true}}, single_file_support = false}
