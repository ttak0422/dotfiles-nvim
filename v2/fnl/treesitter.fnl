((. (require :nvim-treesitter) :setup) {:install_dir args.install_dir})

(let [M (require :nvim-treesitter-textobjects)]
  (M.setup {:select {:lookahead true} :move {:set_jumps true}}))

(set vim.opt.foldmethod :expr)
;; Window-local folds can be inherited when another buffer is first displayed.
(set vim.opt.foldexpr "&filetype ==# 'markdown' || &filetype ==# 'markdown_inline' ? 0 : v:lua.vim.treesitter.foldexpr()")

(vim.api.nvim_create_autocmd :FileType
                             {:callback (fn [event]
                                          (if (or (= event.match :markdown)
                                                  (= event.match :markdown_inline))
                                              (do
                                                ;; Neovim's Markdown ftplugin also starts a highlighter.
                                                (vim.treesitter.stop event.buf)
                                                (set vim.bo.indentexpr "")
                                                ;; The plugin installs this after its FileType callback.
                                                (vim.schedule
                                                  (fn []
                                                    (when (and (vim.api.nvim_buf_is_valid event.buf)
                                                               (or (= (. vim.bo event.buf :ft) :markdown)
                                                                   (= (. vim.bo event.buf :ft) :markdown_inline))
                                                               (= (vim.fn.exists :#context_commentstring_ft) 1))
                                                      (vim.api.nvim_clear_autocmds
                                                        {:group :context_commentstring_ft
                                                         :event :CursorHold
                                                         :buffer event.buf})))))
                                              (do
                                                (pcall vim.treesitter.start)
                                                (when (= vim.bo.indentexpr "")
                                                  (set vim.bo.indentexpr
                                                       "v:lua.require'nvim-treesitter'.indentexpr()")))))})

(set vim.g.matchup_matchparen_offscreen {:method :popup})
(set vim.g.matchup_treesitter_stopline 500)
(set vim.g.matchup_treesitter_disabled [:markdown :markdown_inline])
