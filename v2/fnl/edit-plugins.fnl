(vim.cmd "
au FileType * setlocal formatoptions-=ro
au WinEnter * checktime
vnoremap ; :
nnoremap ; :
")
