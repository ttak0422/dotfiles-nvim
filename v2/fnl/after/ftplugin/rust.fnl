(let [bufnr (vim.api.nvim_get_current_buf)
      opt {:silent true : bufnr}]
  (each [k v (pairs {:K #(vim.cmd.RustLsp [:hover :actions])})]
    (vim.keymap.set :n k v opt)))
