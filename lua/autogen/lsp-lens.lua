-- [nfnl] Compiled from fnl/lsp-lens.fnl by https://github.com/Olical/nfnl, do not edit.
local M = require("lsp-lens")
local sections = {references = true, implementation = true, definition = false, git_authors = false}
local ignore_filetype = {"prisma"}
return M.setup({enable = true, sections = sections, ignore_filetype = ignore_filetype, include_declaration = false})
