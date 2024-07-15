(let [M (require :dapui)
      icons {:expanded "▾" :collapsed "▸" :current_frame "▸"}
      controls {:element :repl
                :enabled true
                :icons {:disconnect ""
                        :pause ""
                        :play ""
                        :run_last ""
                        :step_back ""
                        :step_into ""
                        :step_out ""
                        :step_over ""
                        :terminate ""}}
      floating {:border :none :mappings {:close [:q :<Esc>]}}
      layouts [{:elements [{:id :scopes :size 0.25}
                           {:id :breakpoints :size 0.25}
                           {:id :stacks :size 0.25}
                           {:id :watches :size 0.25}]
                :position :left
                :size 40}
               {:elements [{:id :repl :size 0.5} {:id :console :size 0.5}]
                :position :bottom
                :size 10}]
      mappings {:edit :e
                :expand [:<CR> :<2-LeftMouse>]
                :open :o
                :remove :d
                :repl :r
                :toggle :t}
      render {:indent 1 :max_value_lines 100}]
  (M.setup {:element_mappings []
            :expand_lines true
            :force_buffers true
            : icons
            : controls
            : floating
            : layouts
            : mappings
            : render}))

(let [colors (require :morimo.colors)
      highlights [[:dapblue colors.lightBlue]
                  [:dapgreen colors.lightGreen]
                  [:dapyellow colors.lightYellow]
                  [:daporange colors.orange]
                  [:dapred colors.lightRed]]
      signs [[:DapBreakpoint "" :dapblue]
             [:DapBreakpointCondition "" :dapblue]
             [:DapBreakpointRejected "" :dapred]
             [:DapStopped "▶" :dapgreen]
             [:DapLogPoint "" :dapyellow]]]
  (each [_ h (ipairs highlights)]
    (vim.api.nvim_set_hl 0 (. h 1) {:fg (. h 2) :bg :none}))
  (each [_ s (ipairs signs)]
    (vim.fn.sign_define (. s 1) {:text (. s 2)
                                 :texthl (. s 3)
                                 :linehl ""
                                 :numhl ""})))
