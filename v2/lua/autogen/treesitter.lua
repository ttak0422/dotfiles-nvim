-- [nfnl] Compiled from v2/fnl/treesitter.fnl by https://github.com/Olical/nfnl, do not edit.
local parser_install_dir = args.parser
vim.opt.runtimepath:prepend(parser_install_dir)
local config = require("nvim-treesitter.configs")
local highlight
local function _1_(_lang, buf)
  local max_filesize = (100 * 1024)
  local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
  return (ok and stats and (stats.size > max_filesize))
end
highlight = {enable = true, disable = _1_, additional_vim_regex_highlighting = false}
local indent = {enable = true}
return config.setup({ignore_install = {}, parser_install_dir = parser_install_dir, highlight = highlight, indent = indent, auto_install = false, sync_install = false})
