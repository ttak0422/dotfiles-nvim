" for converter_fuzzy
highlight PmenuFuzzyMatch gui=bold

call ddc#custom#load_config(s:args['ts_config'])

call ddc#enable({ 'context_filetype': 'treesitter' })

call pum#set_option({
      \ 'auto_select': v:true,
      \ 'auto_confirm_time': 0,
      \ 'direction': 'auto',
      \ 'padding': v:false,
      \ 'scrollbar_char': '▌',
      \ 'item_orders': ['abbr', 'space', 'kind', 'space', 'menu'],
      \ 'max_height': 20,
      \ 'use_setline': v:true,
      \ 'offset_cmdcol': 0,
      \ 'offset_cmdrow': 0,
      \ 'preview': v:false,
      \ 'preview_width': 120,
      \ })
set wildoptions-=pum

" https://zenn.dev/kawarimidoll/articles/54e38aa7f55aff
inoremap <expr> / complete_info(['mode']).mode == 'files' && complete_info(['selected']).selected >= 0 ? '<c-x><c-f>' : '/'

" insert completion
inoremap <C-n> <Cmd>call pum#map#select_relative(+1)<CR>
inoremap <C-p> <Cmd>call pum#map#select_relative(-1)<CR>
inoremap <expr> <C-e> pum#visible() ? '<Cmd>call pum#map#cancel()<CR>' : '<End>'
inoremap <C-y> <Cmd>call pum#map#confirm()<CR>
inoremap <C-o> <Cmd>call pum#map#confirm_word()<CR>
inoremap <C-x>      <Cmd>call ddc#map#manual_complete()<CR>
inoremap <C-x><C-x> <Cmd>call ddc#map#manual_complete()<CR>
inoremap <C-x><C-b> <Cmd>call ddc#map#manual_complete(#{ sources: ['buffer'] })<CR>
inoremap <C-x><C-f> <Cmd>call ddc#map#manual_complete(#{ sources: ['file'] })<CR>
inoremap <C-x><C-l> <Cmd>call ddc#map#manual_complete(#{ sources: ['lsp'] })<CR>
inoremap <expr> <C-Space> '<C-n>'

" cmdline completion
cnoremap <expr> <Tab>
      \   wildmenumode()
      \ ? &wildcharm->nr2char()
      \ : pum#visible()
      \ ? '<Cmd>call pum#map#insert_relative(+1, "empty")<CR>'
      \ : ddc#map#manual_complete()

cnoremap <S-Tab> <Cmd>call pum#map#insert_relative(-1)<CR>
cnoremap <expr> <C-n> pum#visible() ? '<Cmd>call pum#map#insert_relative(+1)<CR>' : '<Down>'
cnoremap <expr> <C-p> pum#visible() ? '<Cmd>call pum#map#insert_relative(-1)<CR>' : '<Up>'
cnoremap <expr> <C-e> pum#visible() ? '<Cmd>call pum#map#cancel()<CR>' : '<End>'
cnoremap <C-y> <Cmd>call pum#map#confirm()<CR>
cnoremap <C-o> <Cmd>call pum#map#confirm()<CR>

function! CommandlinePre() abort
  let b:prev_buffer_config = ddc#custom#get_buffer()
  autocmd User DDCCmdlineLeave ++once call CommandlinePost()
  call ddc#enable_cmdline_completion()
endfunction
function! CommandlinePost() abort
  if 'b:prev_buffer_config'->exists()
    call ddc#custom#set_buffer(b:prev_buffer_config)
    unlet b:prev_buffer_config
  endif
endfunction
nnoremap : <Cmd>call CommandlinePre()<CR>:
nnoremap ? <Cmd>call CommandlinePre()<CR>?
nnoremap / <Cmd>call CommandlinePre()<CR>/
