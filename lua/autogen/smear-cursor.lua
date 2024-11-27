-- [nfnl] Compiled from fnl/smear-cursor.fnl by https://github.com/Olical/nfnl, do not edit.
if not vim.g.neovide then
  return require("smear_cursor").setup({smear_between_buffers = true, use_floating_windows = true, legacy_computing_symbols_support = false, smear_between_neighbor_lines = false})
else
  return nil
end
