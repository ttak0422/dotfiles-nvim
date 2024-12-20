(let [other (require :other-nvim)
      window (require :other-nvim.helper.window)
      util (require :other-nvim.helper.util)
      builtinMappings (require :other-nvim.builtin.mappings)
      transformers (require :other-nvim.builtin.transformers)
      mappings [:golang
                ;; java
                {:context "test file nested"
                 :pattern "/src/main/(.*)/(.*)%.java$"
                 :target "/src/test/%1/%2Test.java"}
                {:context "sut file nested"
                 :pattern "/src/test/(.*)/(.*)Test%.java$"
                 :target "/src/main/%1/%2.java"}
                {:context "sut file nested"
                 :pattern "/src/test/(.*)/(.*)Tests%.java$"
                 :target "/src/main/%1/%2.java"}
                ;; typescript/javascript
                {:pattern "(.*).([tj]sx?)$"
                 :target "%1.test.%2"
                 :context :test}
                {:pattern "(.*).([tj]sx?)$"
                 :target "%1.spec.%2"
                 :context :spec}
                {:pattern "(.*).test.([tj]sx?)$"
                 :target "%1.%2"
                 :context :implementation}
                {:pattern "(.*).spec.([tj]sx?)$"
                 :target "%1.%2"
                 :context :implementation}]
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
