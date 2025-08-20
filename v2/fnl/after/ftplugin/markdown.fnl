(each [key value (pairs {; :conceallevel 2
                         :number false
                         :signcolumn :no
                         :foldcolumn :0
                         :listchars "tab:> "
                         :virtualedit :all})]
  (tset vim.opt_local key value))

(each [lhs rhs (pairs {:<LocalLeader>r "<Cmd>Obsidian backlinks<CR>"
                       :<LocalLeader>t "<Cmd>Obsidian toggle_checkbox<CR>"})]
  (vim.keymap.set :n lhs rhs {:buffer true}))
