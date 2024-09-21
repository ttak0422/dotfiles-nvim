((. (require :bqf) :setup) {:func_map {:open :<CR>
                                       :openc :o
                                       :drop :O
                                       :split :<C-s>
                                       :vsplit :<C-v>
                                       ;; open the item in a new tab
                                       :tab :<C-t>
                                       ;; open the item in a new tab but stay in quickfix window
                                       :tabb ""
                                       ;; open the item in a new tab and close quickfix window
                                       :tabc ""
                                       :tabdrop ""
                                       :ptogglemode :zp
                                       :ptoggleitem :p
                                       :ptoggleauto :P
                                       :pscrollup :<C-b>
                                       :pscrolldown :<C-f>
                                       :pscrollorig :zo
                                       :prevfile ""
                                       :nextfile ""
                                       :prevhist ""
                                       :nexthist ""
                                       :lastleave "'\""
                                       :stoggleup :<S-Tab>
                                       :stoggledown :<Tab>
                                       :stogglevm :<Tab>
                                       :stogglebuf "'<Tab>"
                                       :sclear :z<Tab>
                                       :filter :zn
                                       :filterr :zN
                                       :fzffilter ""}})
