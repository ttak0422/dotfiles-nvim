(let [quarto (require :quarto)
      lspFeatures {:enabled true
                   :chunks :curly
                   :languages [:r :python :julia :bash :html]
                   :diagnostics {:enabled true :triggers [:BufWritePost]}
                   :completion {:enabled true}}
      codeRunner {:enabled true
                  :default_method :molten
                  :ft_runners {:python :molten}
                  :never_run [:yaml]}]
  (quarto.setup {:debug false
                 :closePreviewOnExit true
                 : lspFeatures
                 : codeRunner}))
