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
                             (.. " = " variable.value)
                             (.. variable.name " = " variable.value)))
      virt_text_pos ((fn []
                       (if (= (vim.fn.has :nvim-0.10) 1) :inline :eol)))]
  (M.setup {:enabled false
            :enabled_commands true
            :highlight_changed_variables true
            :highlight_new_as_changed false
            :show_stop_reason true
            :commented true
            :only_first_definition true
            :all_references false
            :clear_on_continue false
            : display_callback
            : virt_text_pos
            :all_frames false
            :virt_lines false
            :virt_text_win_col nil}))

;; nvim-dap-repl-highlights
(let [M (require :nvim-dap-repl-highlights)]
  (M.setup))
