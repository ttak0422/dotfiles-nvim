((. (require :image) :setup) {:backend :kitty
                              :integrations []
                              :max_width nil
                              :max_height 20
                              :max_height_window_percentage math.huge
                              :max_width_window_percentage math.huge
                              :window_overlap_clear_enabled true
                              :window_overlap_clear_ft_ignore [:cmp_menu
                                                               :cmp_docs
                                                               ""]})
