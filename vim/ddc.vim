" for converter_fuzzy
highlight PmenuFuzzyMatch gui=bold

call ddc#custom#load_config(s:args['ts_config'])

let g:popup_preview_config = {
      \ 'border': v:true,
      \ 'delay': 100,
      \ 'maxWidth': 100,
      \ 'maxHeight': 30,
      \ 'winblend': 0,
      \ 'debug': v:false,
      \ }
call popup_preview#enable()

let g:signature_help_config = {
      \ 'border': v:true,
      \ 'maxWidth': 100,
      \ 'maxHeight': 30,
      \ 'contentsStyle': 'remainingLabels',
      \ 'viewStyle': 'virtual',
      \ 'onTriggerChar': v:false,
      \ 'multiLabel': v:true,
      \ 'fallbackToBelow': v:false,
      \ }
call signature_help#enable()

call pum#set_option({
      \ 'auto_select': v:true,
      \ 'auto_confirm_time': 0,
      \ 'direction': 'auto',
      \ 'padding': v:false,
      \ 'preview': v:false,
      \ 'preview_delay': 100,
      \ 'preview_width': 100,
      \ 'preview_border': 'single',
      \ 'highlight_preview': 'Pmenu',
      \ 'scrollbar_char': '▌',
      \ 'item_orders': ['kind','space', 'abbr', 'space', 'menu'],
      \ 'max_height': 20,
      \ 'use_setline': v:false,
      \ 'offset_cmdcol': 0,
      \ 'offset_cmdrow': 0,
      \ })
call ddc#enable({ 'context_filetype': 'treesitter' })

set wildoptions-=pum

" https://zenn.dev/kawarimidoll/articles/54e38aa7f55aff
inoremap <expr> / complete_info(['mode']).mode == 'files' && complete_info(['selected']).selected >= 0 ? '<c-x><c-f>' : '/'

" insert completion
inoremap <C-n> <Cmd>call pum#map#select_relative(+1)<CR>
inoremap <C-p> <Cmd>call pum#map#select_relative(-1)<CR>
inoremap <expr> <C-e> pum#visible() ? '<Cmd>call pum#map#cancel()<CR>' : '<End>'
inoremap <C-y> <Cmd>call pum#map#confirm()<CR>
" inoremap <C-o> <Cmd>call pum#map#confirm_word()<CR>
inoremap <C-g>   <Cmd>call pum#map#toggle_preview()<CR>
inoremap <C-x>      <Cmd>call ddc#map#manual_complete()<CR>
inoremap <C-x><C-x> <Cmd>call ddc#map#manual_complete()<CR>
inoremap <C-x><C-b> <Cmd>call ddc#map#manual_complete(#{ sources: ['buffer'] })<CR>
inoremap <C-x><C-f> <Cmd>call ddc#map#manual_complete(#{ sources: ['file'] })<CR>
inoremap <C-x><C-l> <Cmd>call ddc#map#manual_complete(#{ sources: ['lsp'] })<CR>
inoremap <expr> <C-Space> '<C-n>'

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

call ddc#custom#patch_global('sourceParams', #{
      \   lsp: #{
      \     snippetEngine: denops#callback#register({ body -> vsnip#anonymous(body) }),
      \     enableAdditionalTextEdit: v:true,
      \     enableDisplayDetail: v:true,
      \     enableMatchLabel: v:true,
      \     enableResolveItem: v:true,
      \   }
      \ })
lua << EOF
  require("ddc_source_lsp_setup").setup()
EOF
