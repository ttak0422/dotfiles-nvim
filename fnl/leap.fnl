; (let [M (require :leap)]
;   (M.create_default_mappings))
(each [_ K (ipairs [[[:n :x :o] :s "<Plug>(leap-forward)" "Leap forward"]
                    [[:n :x :o] :S "<Plug>(leap-backward)" "Leap backward"]])]
  (vim.keymap.set (. K 1) (. K 2) (. K 3)))
