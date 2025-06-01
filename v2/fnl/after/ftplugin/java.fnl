(local java_path args.java_path)
(local jdtls_jar_pattern args.jdtls_jar_pattern)
(local jdtls_config_path args.jdtls_config_path)
(local java_debug_jar_pattern args.java_debug_jar_pattern)
(local java_test_jar_pattern args.java_test_jar_pattern)
(local lombok_jar_path args.lombok_jar_path)

(local jdtls (require :jdtls))
(local jdtls_dap (require :jdtls.dap))
(local springboot (require :spring_boot))

(fn setup [])

(vim.api.nvim_create_autocmd :BufLeave {:buffer 0 :once true :callback setup})
