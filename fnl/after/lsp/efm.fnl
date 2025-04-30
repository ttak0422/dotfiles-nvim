(let [luacheck (require :efmls-configs.linters.luacheck)
      eslint (require :efmls-configs.linters.eslint)
      yamllint (require :efmls-configs.linters.yamllint)
      statix (require :efmls-configs.linters.statix)
      stylelint (require :efmls-configs.linters.stylelint)
      vint (require :efmls-configs.linters.vint)
      shellcheck (require :efmls-configs.linters.shellcheck)
      pylint (require :efmls-configs.linters.pylint)
      gitlint (require :efmls-configs.linters.gitlint)
      hadolint (require :efmls-configs.linters.hadolint)
      languages {:lua [luacheck]
                 :typescript [eslint]
                 :javascript [eslint]
                 :sh [shellcheck]
                 :yaml [yamllint]
                 :nix [statix]
                 :css [stylelint]
                 :scss [stylelint]
                 :less [stylelint]
                 :saas [stylelint]
                 :vim [vint]
                 :python [pylint]
                 :gitcommit [gitlint]
                 :docker [hadolint]}
      init_options {:documentFormatting true :documentRangeFormatting true}]
  {:single_file_support true
   :filetypes (vim.tbl_keys languages)
   :settings {:rootMarkers [:.git/] : languages}
   : init_options
   : capabilities})
