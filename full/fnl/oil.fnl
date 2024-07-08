(let [M (require :oil)
      columns [:icon]
      border :none
      buf_options {:buflisted false :bufhidden :hide}
      win_options {:wrap false
                   :signcolumn :number
                   :cursorcolumn false
                   :foldcolumn :0
                   :spell false
                   :list false
                   :conceallevel 3
                   :concealcursor :nvic}
      keymaps {:g? :actions.show_help
               :<CR> :actions.select
               :e :actions.select
               :<C-v> :actions.select_vsplit
               :<C-s> :actions.select_split
               :<C-t> :actions.select_tab
               :<C-p> :actions.preview
               :q :actions.close
               :<C-c> :actions.close
               :R :actions.refresh
               :H :actions.parent
               :L :actions.select}
      keymaps_help {: border}
      view_options {:show_hidden true
                    :is_hidden_file (fn [_name _bufnr] false)
                    :is_always_hidden (fn [_name _bufnr] false)
                    :sort [[:type :asc] [:name :asc]]}
      preview {:max_width 0.9
               :min_width [40 0.4]
               :width nil
               :max_height 0.9
               :min_height [5 0.1]
               :height nil
               : border
               :win_options {:winblend 0}
               :update_on_cursor_moved true}
      progress {:max_width 0.9
                :min_width [40 0.4]
                :width nil
                :max_height [10 0.9]
                :min_height [5 0.1]
                :height nil
                : border
                :minimized_border :none
                :win_options {:winblend 0}}
      ssh {:border :none}
      lsp_file_methods {:timeout_ms 1000 :autosave_changes false}]
  (M.setup {:default_file_explorer false
            :delete_to_trash true
            :skip_confirm_for_simple_edits false
            :prompt_save_on_select_new_entry true
            :cleanup_delay_ms 2000
            :constrain_cursor :editable
            :experimental_watch_for_changes false
            :use_default_keymaps false
            : lsp_file_methods
            : columns
            : buf_options
            : win_options
            : keymaps
            : keymaps_help
            : view_options
            : preview
            : progress
            : ssh}))

(let [M (require :oil-vcs-status)
      status_const (require :oil-vcs-status.constant.status)
      StatusType status_const.StatusType
      status_symbol {StatusType.Added ""
                     StatusType.Copied "󰆏"
                     StatusType.Deleted ""
                     StatusType.Ignored ""
                     StatusType.Modified ""
                     StatusType.Renamed ""
                     StatusType.TypeChanged "󰉺"
                     StatusType.Unmodified " "
                     StatusType.Unmerged ""
                     StatusType.Untracked ""
                     StatusType.External ""
                     StatusType.UpstreamAdded "󰈞"
                     StatusType.UpstreamCopied "󰈢"
                     StatusType.UpstreamDeleted ""
                     StatusType.UpstreamIgnored " "
                     StatusType.UpstreamModified "󰏫"
                     StatusType.UpstreamRenamed ""
                     StatusType.UpstreamTypeChanged "󱧶"
                     StatusType.UpstreamUnmodified " "
                     StatusType.UpstreamUnmerged ""
                     StatusType.UpstreamUntracked " "
                     StatusType.UpstreamExternal ""}
      status_priority {StatusType.UpstreamIgnored 0
                       StatusType.Ignored 0
                       StatusType.UpstreamUntracked 1
                       StatusType.Untracked 1
                       StatusType.UpstreamUnmodified 2
                       StatusType.Unmodified 2
                       StatusType.UpstreamExternal 2
                       StatusType.External 2
                       StatusType.UpstreamCopied 3
                       StatusType.UpstreamRenamed 3
                       StatusType.UpstreamTypeChanged 3
                       StatusType.UpstreamDeleted 4
                       StatusType.UpstreamModified 4
                       StatusType.UpstreamAdded 4
                       StatusType.UpstreamUnmerged 5
                       StatusType.Copied 13
                       StatusType.Renamed 13
                       StatusType.TypeChanged 13
                       StatusType.Deleted 14
                       StatusType.Modified 14
                       StatusType.Added 14
                       StatusType.Unmerged 15}
      vcs_specific {:git {:status_update_debounce 200}}]
  (M.setup {":fs_event_debounce" 500
            : status_symbol
            : status_priority
            : vcs_specific}))
