(let [M (require :aerial)
      backends [:treesitter :lsp]
      icons {:Text "󰉿"
             :Method "󰊕"
             :Function "󰊕"
             :Constructor ""
             :Field "󰜢"
             :Variable "󰀫"
             :Class "󰠱"
             :Interface ""
             :Module ""
             :Property "󰜢"
             :Unit "󰑭"
             :Value "󰎠"
             :Enum ""
             :Keyword "󰌋"
             :Snippet ""
             :Color "󰏘"
             :File "󰈙"
             :Reference "󰈇"
             :Folder "󰉋"
             :EnumMember ""
             :Constant "󰏿"
             :Struct "󰙅"
             :Event ""
             :Operator "󰆕"
             :TypeParameter "󰗴"}
      layout {:max_width 0.25
              :min_width 0.15
              :default_direction :prefer_left
              :placement :window}
      keymaps {:g? :actions.show_help
               :<CR> :actions.jump
               :<2-LeftMouse> :actions.jump
               :<C-v> :actions.jump_vsplit
               :<C-s> :actions.jump_split
               :p :actions.scroll
               :<C-j> :actions.down_and_scroll
               :<C-k> :actions.up_and_scroll
               "{" :actions.prev
               "}" :actions.next
               "[[" :actions.prev_up
               "]]" :actions.next_up
               :q :actions.close
               :o :actions.tree_toggle
               :za :actions.tree_toggle
               :O :actions.tree_toggle_recursive
               :zA :actions.tree_toggle_recursive
               :l :actions.tree_open
               :zo :actions.tree_open
               :L :actions.tree_open_recursive
               :zO :actions.tree_open_recursive
               :h :actions.tree_close
               :zc :actions.tree_close
               :H :actions.tree_close_recursive
               :zC :actions.tree_close_recursive
               :zr :actions.tree_increase_fold_level
               :zR :actions.tree_open_all
               :zm :actions.tree_decrease_fold_level
               :zM :actions.tree_close_all
               :zx :actions.tree_sync_folds
               :zX :actions.tree_sync_folds}
      filter_kind [:Class
                   :Constructor
                   :Enum
                   :Function
                   :Method
                   :Interface
                   :Module
                   :Method
                   :Struct]
      ignore {:unlisted_buffers false
              :diff_windows true
              :filetypes {}
              :buftypes :special
              :wintypes :special}
      treesitter {:update_delay 500}
      lsp {:diagnostics_trigger_update false
           :update_when_errors true
           :update_delay 600}
      guides {:mid_item "├─"
              :last_item "└─"
              :nested_top "│ "
              :whitespace "  "}]
  (M.setup {: backends
            : icons
            : layout
            : keymaps
            : filter_kind
            : ignore
            : treesitter
            : lsp
            : guides}))
