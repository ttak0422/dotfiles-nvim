for file in glob(s:args['root'] . '/*.*', 1, 1)
  call denippet#load(file)
endfor

" inoremap <C-l> <Plug>(denippet-expand)
inoremap <expr> <Tab> denippet#jumpable() ? '<Plug>(denippet-jump-next)' : '<Tab>'
snoremap <expr> <Tab> denippet#jumpable() ? '<Plug>(denippet-jump-next)' : '<Tab>'
inoremap <expr> <S-Tab> denippet#jumpable(-1) ? '<Plug>(denippet-jump-prev)' : '<S-Tab>'
snoremap <expr> <S-Tab> denippet#jumpable(-1) ? '<Plug>(denippet-jump-prev)' : '<S-Tab>'
