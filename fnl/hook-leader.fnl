(vim.api.nvim_del_keymap :n :<Leader>)

(let [opts {:noremap true :silent true}
      desc (fn [d] {:noremap true :silent true :desc d})
      cmd (fn [c] (.. :<cmd> c :<cr>))
      lcmd (fn [c] (cmd (.. "lua " c)))
      mk_toggle ((fn []
                   (let [state {:open? false :pre_id nil}]
                     (fn [id mod args]
                       (fn []
                         (let [T (require :toolwindow)]
                           (if (not= state.pre_id id)
                               (do
                                 (T.open_window mod args)
                                 (tset state :open? true))
                               (if state.open?
                                   (do
                                     (T.close)
                                     (tset state :open? false))
                                   (do
                                     (T.open_window mod args)
                                     (tset state :open? true))))
                           (tset state :pre_id id)))))))
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
         [:<Leader>fp
          (cmd "Ddu -name=fd file_fd")
          (desc "search by file name")]
         [:<Leader>fP (cmd "Ddu -name=ghq ghq") (desc "search repo (ghq)")]
         [:<Leader>fru
          (cmd "Ddu -name=mru mru")
          (desc "MRU (Most Recently Used files)")]
         [:<Leader>frw
          (cmd "Ddu -name=mrw mrw")
          (desc "MRW (Most Recently Written files)")]
         ;; mark
         [:<leader>mq (cmd :MarksQFListBuf) (desc "marks in current buffer")]
         [:<leader>mQ (cmd :MarksQFListGlobal) (desc "marks in all buffer")]
         ;; undo
         [:<leader>U (cmd :UndotreeToggle (desc "toggle undotree"))]
         ;; neorg
         [:<Leader>nn
          (cmd "Neorg journal today")
          (desc "Enter Neorg (today journal)")]
         [:<Leader>no (cmd "Neorg toc") (desc "Show Neorg TOC")]
         [:<Leader>N (cmd :Neorg) (desc "Enter Neorg")]
         [:<Leader>fn
          (cmd "Neorg keybind norg core.integrations.telescope.find_linkable")
          (desc "find Neorg linkable")]
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
          (desc "toggle minimap")]
         [:<leader>tj
          (cmd "lua require('treesj').toggle({ split = { recursive = false }})")
          (desc "toggle split/join")]
         [:<leader>tJ
          (cmd "lua require('treesj').toggle({ split = { recursive = true }})")
          (desc "toggle recursive split/join")]
         [:<leader>tq (mk_toggle 1 :quickfix nil) (desc "toggle quickfix")]
         [:<leader>td
          (mk_toggle 2 :trouble
                     {:mode :diagnostics
                      :filter {:buf 0}})
          (desc "toggle diagnostics (document)")]
         [:<leader>tD
          (mk_toggle 3 :trouble {:mode :diagnostics})
          (desc "toggle diagnostics (workspace)")]]
      V [[:<Leader>T (cmd :Translate)] [:<leader>r (cmd :FlowRunSelected)]]]
  (each [_ K (ipairs N)]
    (vim.keymap.set :n (. K 1) (. K 2) (or (. K 3) opts)))
  (each [_ K (ipairs V)]
    (vim.keymap.set :n (. K 1) (. K 2) (or (. K 3) opts))))

(vim.schedule (fn []
                (vim.api.nvim_feedkeys (vim.api.nvim_replace_termcodes :<Leader>
                                                                       true
                                                                       false
                                                                       true)
                                       :m true)))
