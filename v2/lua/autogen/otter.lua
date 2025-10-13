-- [nfnl] v2/fnl/otter.fnl
local otter = require("otter")
local lsp
local function _1_(_, bufnr)
  return (vim.fs.root((bufnr or 0), {".git", "_quarto.yml", "package.json"}) or vim.fn.getcwd(0))
end
lsp = {diagnostic_update_events = {"BufWritePost"}, root_dir = _1_}
local buffers = {write_to_disk = true, preambles = {}, postambles = {}, ignore_pattern = {python = "^(%s*[%%!].*)"}}
return otter.setup({lsp = lsp, buffers = buffers, strip_wrapping_quote_characters = {"'", "\"", "`"}, handle_leading_whitespace = true, extensions = {}, verbose = {no_code_found = false}, debug = false})
