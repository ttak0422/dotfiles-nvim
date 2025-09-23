((. (require :lazydev) :setup) {:library []})

((. (require :blink.cmp) :add_source_provider) :lazydev
                                               {:name :LazyDev
                                                :module :lazydev.integrations.blink
                                                :score_offset 100})
