" setup
call ddu#custom#load_config(s:args['ts_config'])

function s:ddu_send_all_to_qf() abort
  call ddu#ui#do_action('clearSelectAllItems')
  call ddu#ui#do_action('toggleAllItems')
  call ddu#ui#do_action('itemAction', { 'name': 'quickfix'})
endfunction

function s:ddu_filter_open() abort
  call ddu#ui#save_cmaps([
        \  '<C-n>', '<C-p>', '<C-c>', '<C-q>', '<CR>',
        \ ])
  cnoremap <C-n> <Cmd>call ddu#ui#do_action('cursorNext', #{ loop: v:true })<CR>
  cnoremap <C-p> <Cmd>call ddu#ui#do_action('cursorPrevious', #{ loop: v:true })<CR>
  cnoremap <C-c> <ESC><Cmd>call ddu#ui#do_action('quit')<CR>
  cnoremap <C-q> <ESC><Cmd>call <SID>ddu_send_all_to_qf()<CR>
  cnoremap <CR>  <ESC><Cmd>call ddu#ui#do_action('itemAction')<CR>
endfunction

function s:ddu_filter_close() abort
  call ddu#ui#restore_cmaps()
endfunction

au User Ddu:uiOpenFilterWindow call s:ddu_filter_open()
au User Ddu:uiCloseFilterWindow call s:ddu_filter_close()
