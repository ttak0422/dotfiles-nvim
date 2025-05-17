(local harpoon (require :harpoon))

(harpoon.setup {:settings {:save_on_toggle false
                           :sync_on_ui_close false
                           :key #(vim.loop.cwd)}})
