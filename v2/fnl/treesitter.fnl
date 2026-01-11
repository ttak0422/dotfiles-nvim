((. (require :nvim-treesitter) :setup) {:install_dir args.install_dir})

(let [M (require :nvim-treesitter-textobjects)]
  (M.setup {:select {:lookahead true} :move {:set_jumps true}}))

(set vim.opt.foldmethod :expr)
(set vim.opt.foldexpr "v:lua.vim.treesitter.foldexpr()")

(vim.api.nvim_create_autocmd :FileType
                             {:callback (fn []
                                          (pcall vim.treesitter.start)
                                          (when (= vim.bo.indentexpr "")
                                            (set vim.bo.indentexpr
                                                 "v:lua.require'nvim-treesitter'.indentexpr()")))})
