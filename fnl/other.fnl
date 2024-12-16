(let [other (require :other-nvim)
      window (require :other-nvim.helper.window)
      util (require :other-nvim.helper.util)
      builtinMappings (require :other-nvim.builtin.mappings)
      transformers (require :other-nvim.builtin.transformers)
      mappings [:golang]
      transformers {:camelToKebap transformers.camelToKebap
                    :kebapToCamel transformers.kebapToCamel
                    :pluralize transformers.pluralize
                    :singularize transformers.singularize}
      keybindings {:<cr> "open_file_by_command()"
                   :<esc> "close_window()"
                   :q "close_window()"
                   :<C-c> "close_window()"
                   :o "open_file()"
                   :t "open_file_tabnew()"
                   :v "open_file_vs()"
                   :s "open_file_sp()"}
      style {:border :none
             :seperator "|"
             :newFileIndicator "(* new *)"
             :width 0.7
             :minHeight 2}]
  (other.setup {:showMissingFiles true
                :rememberBuffers true
                : mappings
                : transformers
                : keybindings
                : style}))
