;; <ESC>1回 → ノーマルモードに遷移、<ESC>2回 → ESCを入力
(vim.cmd "
tnoremap <ESC> <c-\\><c-n><Plug>(esc)
nnoremap <Plug>(esc)<ESC> i<ESC>
         ")
