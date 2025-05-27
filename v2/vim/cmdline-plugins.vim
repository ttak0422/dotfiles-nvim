cnoremap <expr> <C-a> '<Home>'
cnoremap <expr> <C-e> '<End>'
cnoremap <expr> <C-b> '<Left>'
cnoremap <expr> <C-f> '<Right>'
cabbrev <expr> r getcmdtype() .. getcmdline() ==# ":r" ? [getchar(), ""][1] .. "%s//g<Left><Left>" : (getcmdline() ==# "'<,'>r" ?  [getchar(), ""][1] .. "s//g<Left><Left>" : "r")
