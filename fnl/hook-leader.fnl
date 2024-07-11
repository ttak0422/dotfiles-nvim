(vim.api.nvim_del_keymap :n :<Leader>)

(let [opts {:noremap true :silent true}
      desc (fn [d] {:noremap true :silent true :desc d})
      cmd (fn [c] (.. :<cmd> c :<cr>))
      lcmd (fn [c] (cmd (.. "lua " c)))
      N [;; finder
         [:<Leader>ff
          (cmd "Telescope live_grep_args")
          (desc "search by content")]
         [:<Leader>fF (cmd "Telescope ast_grep") (desc "search by AST")]
         [:<Leader>ft
          (cmd "Telescope sonictemplate templates")
          (desc "search templates")]
         [:<Leader>fh (cmd :Legendary) (desc "Search command palette")]
         [:<Leader>H
          (lcmd "require('harpoon').ui:toggle_quick_menu(require('harpoon'):list(),{border='none'})")
          (desc "Show registered file")]
         [:<Leader>ha
          (lcmd "require('harpoon'):list():add()")
          (desc "Register file")]
         ;; neorg
         [:<Leader>nn
          (cmd "Neorg journal today")
          (desc "Enter Neorg (today journal)")]
         [:<Leader>no (cmd "Neorg toc") (desc "Show Neorg TOC")]
         [:<Leader>N (cmd :Neorg) (desc "Enter Neorg")]
         ;; git
         [:<Leader>G (cmd :Neogit) (desc "Neovim git client")]
         ;; filter
         [:<Leader>tb
          (lcmd "require('lir.float').toggle()")
          (desc "Toggle lir")]
         [:<Leader>tB (lcmd "require('oil').open()") (desc "Toggle oil")]
         ;; buffer
         [:<leader>q (cmd :BufDel)]
         [:<leader>Q (cmd :BufDel!)]
         ;; toggle
         [:<leader>tm
          (lcmd "require('codewindow').toggle_minimap()")
          (desc "toggle minimap")]]]
  (each [_ K (ipairs N)]
    (vim.keymap.set :n (. K 1) (. K 2) (or (. K 3) opts))))

(vim.schedule (fn []
                (vim.api.nvim_feedkeys (vim.api.nvim_replace_termcodes :<Leader>
                                                                       true
                                                                       false
                                                                       true)
                                       :m true)))
