((. (require :lazydev) :setup) {:library []
                                :enabled (fn [root_dir]
                                           (not (vim.uv.fs_stat (.. root_dir
                                                                    :/.luarc.json))))})

((. (require :blink.cmp) :add_source_provider) :lazydev
                                               {:name :LazyDev
                                                :module :lazydev.integrations.blink
                                                :score_offset 100})
