(local incline (require :incline))

(local ignored-buftypes {:nofile true :prompt true :help true :quickfix true})

(local maven-prefixes
       {:java [:src/main/java/ :src/test/java/]
        :kotlin [:src/main/kotlin/ :src/test/kotlin/]
        :scala [:src/main/scala/ :src/test/scala/]})

(fn highlighted [text group]
  {1 text : group})

(fn emphasized [text color]
  {1 text :guifg color :gui :bold})

(fn normalize-path [path filetype]
  (var result path)
  (each [_ prefix (ipairs (or (. maven-prefixes filetype) []))]
    (when (vim.startswith result prefix)
      (set result (string.sub result (+ (length prefix) 1)))))
  result)

(fn file-context [buf win]
  (let [name (vim.api.nvim_buf_get_name buf)
        git-root (and (not= name "") (vim.fs.root name [:.git]))
        filename (vim.fn.fnamemodify name ":t")
        relative (if git-root
                     (string.sub name (+ (length git-root) 2))
                     (vim.fn.fnamemodify name ":."))
        path (-> (vim.fn.fnamemodify relative ":h")
                 (normalize-path (. vim.bo buf :filetype)))
        path (if (< (vim.api.nvim_win_get_width win) 100)
                 (vim.fn.pathshorten path)
                 path)]
    {:filename (if (= filename "") "[No Name]" filename) : path}))

(fn append-git [result buf]
  (let [status (?. vim.b buf :gitsigns_status_dict)]
    (when status
      (each [_ change (ipairs [[:added "  " vim.g.terminal_color_10]
                               [:changed "  " vim.g.terminal_color_12]
                               [:removed "  " vim.g.terminal_color_9]])]
        (let [[key icon color] change
              count (or (. status key) 0)]
          (when (> count 0)
            (table.insert result (emphasized (.. icon count) color))))))))

(fn append-diagnostics [result buf]
  (each [_ diagnostic (ipairs [[vim.diagnostic.severity.ERROR
                                "  "
                                :DiagnosticError]
                               [vim.diagnostic.severity.WARN
                                "  "
                                :DiagnosticWarn]])]
    (let [[severity icon group] diagnostic
          count (length (vim.diagnostic.get buf {: severity}))]
      (when (> count 0)
        (table.insert result (highlighted (.. icon count) group))))))

(fn append-window-context [result props]
  (when props.focused
    (table.insert result "  ")
    (let [cwd (vim.fn.fnamemodify (vim.fn.getcwd) ":t")]
      (table.insert result (if (= cwd "") :ROOT cwd)))
    (let [status (?. vim.b props.buf :gitsigns_status_dict)]
      (when status
        (let [head (or status.head "")
              dirty (> (+ (or status.added 0) (or status.changed 0)
                          (or status.removed 0)) 0)]
          (when (not= head "")
            (table.insert result (.. " (" head (if dirty "*" "") ")"))))))
    (let [[line column] (vim.api.nvim_win_get_cursor props.win)]
      (table.insert result (highlighted (.. "  "
                                            (string.format "%4d,%-3d" line
                                                           (+ column 1))
                                            " ")
                                        :WinBar)))))

(fn render [props]
  (let [filetype (. vim.bo props.buf :filetype)]
    (when (not (or (vim.startswith filetype :git) (= filetype :Trouble)
                   (= filetype :skk-terminal-input)))
      (let [{: filename : path} (file-context props.buf props.win)
            result [" "]]
        (append-git result props.buf)
        (append-diagnostics result props.buf)
        (table.insert result " ")
        (when (. vim.bo props.buf :modified)
          (table.insert result (highlighted " " :DiagnosticWarn)))
        (table.insert result (highlighted filename :Title))
        (when (and (not= path "") (not= path "."))
          (table.insert result " ")
          (table.insert result (highlighted path :WinBar)))
        (append-window-context result props)
        result))))

(incline.setup {:window {:padding 0
                         :margin {:horizontal 0 :vertical 0}
                         :zindex 30
                         :placement {:horizontal :right :vertical :top}}
                :hide {:cursorline :smart :focused_win false :only_win false}
                :ignore {:unlisted_buffers false
                         :floating_wins true
                         :buftypes (fn [_ buftype]
                                     (not= (. ignored-buftypes buftype) nil))
                         :filetypes [:Trouble :skk-terminal-input]}
                :highlight {:groups {:InclineNormal {:group :WinBar
                                                     :default false}
                                     :InclineNormalNC {:group :WinBarNC
                                                       :default false}}}
                : render})

(let [group (vim.api.nvim_create_augroup :incline-user-refresh {:clear true})
      refresh #(vim.schedule incline.refresh)]
  (vim.api.nvim_create_autocmd [:BufModifiedSet :DiagnosticChanged :DirChanged]
                               {: group :callback refresh})
  (vim.api.nvim_create_autocmd :User
                               {: group
                                :pattern :GitSignsUpdate
                                :callback refresh}))
