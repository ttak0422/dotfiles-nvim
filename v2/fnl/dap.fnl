;; dap
(local dap (require :dap))

(set dap.listeners.before.event_terminated.dapui_config (fn []))
(set dap.listeners.before.event_exited.dapui_config (fn []))

;; virtual text
(local virtual-text (require :nvim-dap-virtual-text))
(virtual-text.setup {:virt_text_pos :inline
                     :display_callback (fn [variable
                                            _buf
                                            _stackframe
                                            _node
                                            _options]
                                         (.. " = "
                                             (variable.value:gsub "%s+" " ")))})

;; repl highlights
(local dap-repl-highlights (require :nvim-dap-repl-highlights))
(dap-repl-highlights.setup)
