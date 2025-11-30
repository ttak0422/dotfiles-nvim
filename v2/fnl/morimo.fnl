(each [_ p (ipairs [:nvim-notify
                    :treesitter
                    :gitsigns
                    :lir
                    :dap
                    :git-conflict
                    :lir])]
  ((. (require :morimo) :load) p))
