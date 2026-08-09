(local koe (require :koe))

(koe.setup {:locale "ja-JP"})
(vim.keymap.set :i :<M-v> koe.toggle
                {:silent true :desc "koe: dictation toggle"})
