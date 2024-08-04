" setup
call ddu#custom#load_config(s:args['ts_config'])

function s:ddu_send_all_to_qf() abort
  call ddu#ui#do_action('clearSelectAllItems')
  call ddu#ui#do_action('toggleAllItems')
  call ddu#ui#do_action('itemAction', { 'name': 'quickfix'})
endfunction

function s:ddu_ff_filter_open() abort
  call ddu#ui#ff#save_cmaps([
        \  '<C-f>', '<C-b>', '<C-c>', '<C-q>', '<CR>',
        \ ])
  cnoremap <C-n> <Cmd>call ddu#ui#do_action('cursorNext', #{ loop: v:true })<CR>
  cnoremap <C-p> <Cmd>call ddu#ui#do_action('cursorPrevious', #{ loop: v:true })<CR>
  cnoremap <C-c> <ESC><Cmd>call ddu#ui#do_action('quit')<CR>
  cnoremap <C-q> <ESC><Cmd>call <SID>ddu_send_all_to_qf()<CR>
  cnoremap <CR>  <ESC><Cmd>call ddu#ui#do_action('itemAction')<CR>
endfunction

function s:ddu_ff_filter_close() abort
  call ddu#ui#ff#restore_cmaps()
endfunction

au User Ddu:ui:ff:openFilterWindow call s:ddu_ff_filter_open()
au User Ddu:ui:ff:closeFilterWindow call s:ddu_ff_filter_close()
