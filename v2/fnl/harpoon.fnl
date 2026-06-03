(local harpoon (require :harpoon))

(fn display [item]
  (let [value (or item.value "")
        repo (vim.fn.fnamemodify (vim.uv.cwd) ":t")
        fname (vim.fn.fnamemodify value ":t")
        dir (vim.fn.fnamemodify value ":h")]
    (if (or (= dir ".") (= dir ""))
        (string.format "%s  %s" fname repo)
        (string.format "%s  %s/%s" fname repo dir))))

(harpoon.setup {:settings {:save_on_toggle false
                           :sync_on_ui_close false
                           :key #(vim.uv.cwd)}
                :default {:display display}})
