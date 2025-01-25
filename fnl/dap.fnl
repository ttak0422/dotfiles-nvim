;; dap
(let [dap (setmetatable {:vscode (require :dap.ext.vscode)}
                        {:__index (require :dap)})]
  (tset dap.listeners.before.event_terminated :dapui_config (fn []))
  (tset dap.listeners.before.event_exited :dapui_config (fn []))
  (dap.vscode.load_launchjs))

;; nvim-dap-virtual-text
(let [M (require :nvim-dap-virtual-text)
      display_callback (fn [variable _buf _stackframe _node options]
                         (if (= options.virt_text_pos :inline)
                             (.. " = " (variable.value:gsub "%s+" " "))
                             (.. variable.name " = "
                                 (variable.value:gsub "%s+" " "))))
      virt_text_pos :inline]
  (M.setup {:enabled true
            :enabled_commands true
            :highlight_changed_variables true
            :highlight_new_as_changed false
            :show_stop_reason true
            :commented false
            :only_first_definition true
            :all_references false
            :clear_on_continue false
            : display_callback
            : virt_text_pos
            :all_frames false
            :virt_lines false
            :virt_text_win_col nil}))

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

;; nvim-dap-repl-highlights
(let [M (require :nvim-dap-repl-highlights)]
  (M.setup))
