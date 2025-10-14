(if (not vim.g.neovide)
    ((. (require :image) :setup) {:backend :kitty
                                  :integrations {:markdown {:enabled true
                                                            :clear_in_insert_mode false
                                                            :download_remote_images true
                                                            :only_render_image_at_cursor true
                                                            :only_render_image_at_cursor_mode :popup
                                                            :floating_windows false
                                                            :filetypes [:markdown
                                                                        :vimwiki]}}
                                  :max_width nil
                                  :max_height 20
                                  :max_height_window_percentage math.huge
                                  :max_width_window_percentage math.huge
                                  :window_overlap_clear_enabled true
                                  :window_overlap_clear_ft_ignore [:cmp_menu
                                                                   :cmp_docs
                                                                   ""]}))
