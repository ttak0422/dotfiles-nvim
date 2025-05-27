-- [nfnl] Compiled from v2/fnl/edit-plugins.fnl by https://github.com/Olical/nfnl, do not edit.
return vim.cmd("\nau FileType * setlocal formatoptions-=ro\nau WinEnter * checktime\nvnoremap ; :\nnnoremap ; :\n")
