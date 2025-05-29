(local dressing (require :dressing))

(local input {:enabled true
              :default_prompt "Input:"
              :title_pos :center
              :start_mode :insert
              :border :single
              :relative :cursor
              :prefer_width 0.4
              :mappings {:n {:<ESC> :close :<CR> :Confirm}
                         :i {:<C-c> :Close
                             :<CR> :Confirm
                             :<Up> :HistoryPrev
                             :<Down> :HistoryNext}}})

(local select
       {:enabled true
        :backend [:telescope :builtin]
        :trim_prompt true
        :telescope ((. (require :telescope.themes) :get_cursor))})

(dressing.setup {: input : select})
