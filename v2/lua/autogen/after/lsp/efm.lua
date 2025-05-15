-- [nfnl] Compiled from v2/fnl/after/lsp/efm.fnl by https://github.com/Olical/nfnl, do not edit.
local languages = {}
local init_options = {documentFormatting = true, documentRangeFormatting = true}
return {single_file_support = true, filetypes = vim.tbl_keys(languages), settings = {rootMarkers = {".git/"}, languages = languages}, init_options = init_options}
