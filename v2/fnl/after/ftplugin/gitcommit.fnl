(vim.opt_local.iskeyword:append "-")
(set vim.bo.bufhidden :wipe)

(fn prefill-ticket []
  (let [buf (vim.api.nvim_get_current_buf)
        name (vim.api.nvim_buf_get_name buf)
        file (vim.uv.fs_realpath name)]
    (when (and (= vim.bo.filetype :gitcommit)
               file (= (vim.fs.basename file) :COMMIT_EDITMSG)
               (not vim.b.ticket_prefix_checked)
               (not vim.bo.modified) vim.bo.modifiable (not vim.bo.readonly))
      (set vim.b.ticket_prefix_checked true)
      (let [gitdir (vim.fs.dirname file)
            tick (vim.api.nvim_buf_get_changedtick buf)
            env (vim.fn.environ)]
        ;; The persistent editor may belong to another repository or worktree.
        (each [_ key (ipairs [:GIT_DIR :GIT_WORK_TREE :GIT_COMMON_DIR :GIT_NAMESPACE])]
          (tset env key nil))
        (fn git [...]
          (let [argv [:git (.. "--git-dir=" gitdir)]
                _ (vim.list_extend argv [...])
                (ok result) (pcall #(: (vim.system argv {:text true :clear_env true : env})
                                       :wait 300))]
            (when ok result)))
        (fn operation? []
          (var active false)
          (each [_ path (ipairs [:MERGE_HEAD :SQUASH_MSG :CHERRY_PICK_HEAD :REVERT_HEAD
                                :rebase-merge :rebase-apply :sequencer])]
            (when (vim.uv.fs_stat (.. gitdir "/" path))
              (set active true)))
          active)
        (when (not (operation?))
          (let [branch (git :symbolic-ref :--quiet :--short :HEAD)
                ticket (and branch (= branch.code 0)
                            (branch.stdout:match "^feature/([A-Z][A-Z0-9]*%-%d+)_[A-Za-z0-9][A-Za-z0-9_-]*\n$"))]
            (when ticket
              (var comment-prefix nil)
              (let [value (git :config :--get :core.commentString)]
                (when value
                  (if (= value.code 0)
                      (set comment-prefix (value.stdout:gsub "\n$" ""))
                      (= value.code 1)
                      (let [char (git :config :--get :core.commentChar)]
                        (when char
                          (if (= char.code 1)
                              (set comment-prefix "#")
                              (and (= char.code 0) (not= char.stdout "auto\n"))
                              (set comment-prefix (char.stdout:gsub "\n$" ""))))))))
              (when (and comment-prefix (not= comment-prefix "")
                         (vim.api.nvim_buf_is_valid buf)
                         (= (vim.api.nvim_get_current_buf) buf)
                         (= (vim.api.nvim_buf_get_name buf) name)
                         (= (vim.api.nvim_buf_get_changedtick buf) tick)
                         (= vim.bo.filetype :gitcommit)
                         (not vim.bo.modified) vim.bo.modifiable (not vim.bo.readonly)
                         (not (operation?)))
                (let [lines (vim.api.nvim_buf_get_lines buf 0 -1 false)
                      prefix (.. ticket " ")]
                  (var empty true)
                  (each [_ line (ipairs lines)]
                    (when (and (not (line:match "^%s*$"))
                               (not= (line:sub 1 (length comment-prefix)) comment-prefix))
                      (set empty false)))
                  ;; shortcut: an entirely empty amend has no reliable operation marker;
                  ;; pass operation context from the caller if that must be excluded too.
                  (when empty
                    (vim.api.nvim_buf_set_lines buf 0 (if (string.match (. lines 1) "^%s*$") 1 0)
                                                false [prefix])
                    (vim.api.nvim_win_set_cursor 0 [1 (length ticket)])))))))))))

;; FileType runs during the read; BufWinEnter keeps the insertion marked modified.
(vim.api.nvim_create_autocmd :BufWinEnter
                             {:buffer (vim.api.nvim_get_current_buf)
                              :once true
                              :callback prefill-ticket})
