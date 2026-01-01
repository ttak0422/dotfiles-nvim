(local default_settings
       {:rust-analyzer {:files {:excludeDirs [:.direnv
                                              :.git
                                              :.venv
                                              :bin
                                              :node_modules
                                              :target]}}})

(set vim.g.rustaceanvim {:server {: default_settings}})
