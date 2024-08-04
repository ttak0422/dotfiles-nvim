setlocal cursorline
nnoremap <buffer> i <Cmd>call ddu#ui#do_action('openFilterWindow')<CR>
nnoremap <buffer> q <Cmd>call ddu#ui#do_action('quit')<CR>
nnoremap <buffer> <C-c> <Cmd>call ddu#ui#do_action('quit')<CR>
nnoremap <buffer> <CR> <Cmd>call ddu#ui#do_action('itemAction')<CR>
nnoremap <buffer> <Space> <Cmd>call ddu#ui#do_action('toggleSelectItem')<CR>
nnoremap <buffer><C-n> <Cmd>call ddu#ui#do_action('cursorNext', #{ loop: v:true })<CR>
nnoremap <buffer><C-p> <Cmd>call ddu#ui#do_action('cursorPrevious', #{ loop: v:true })<CR>
