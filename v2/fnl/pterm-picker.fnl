(local pterm (require :pterm))
(local telescope (require :telescope))
(local actions (require :telescope.actions))
(local action-state (require :telescope.actions.state))
(local parser (require :telescope-live-grep-args.prompt_parser))

(telescope.load_extension :pterm)

(fn create-session [prompt-bufnr]
  (let [prompt (vim.trim (action-state.get_current_line))
        names (pterm.list)
        ;; Preserve exact existing names, including names containing spaces.
        argv (if (vim.tbl_contains names prompt) [prompt] (parser.parse prompt false))
        name (. argv 1)
        command (. argv 2)]
    (if (or (= name nil) (= name ""))
        (actions.close prompt-bufnr)
        (and command (vim.tbl_contains names name))
        (vim.notify (.. "Session '" name "' already exists; select it without a command")
                    vim.log.levels.ERROR)
        (and command (= (vim.fn.executable command) 0))
        (vim.notify (.. "Executable not found: " command) vim.log.levels.ERROR)
        (do
          (actions.close prompt-bufnr)
          (let [(ok err) (pcall pterm.open name argv)]
            (when (not ok)
              (vim.notify (.. "Failed to open session '" name "': " (tostring err))
                          vim.log.levels.ERROR)))))))

(let [extension telescope.extensions.pterm
      sessions extension.sessions
      configured (fn [opts]
                   (let [opts (vim.tbl_extend :force {} (or opts {}))
                         attach opts.attach_mappings]
                     (set opts.prompt_title (or opts.prompt_title
                                                "pterm sessions | new: name [command args...]"))
                     (set opts.attach_mappings
                          (fn [prompt-bufnr map]
                            ;; Keep the upstream search/selection and preview behavior.
                            (actions.select_default:replace_if
                              #(= (action-state.get_selected_entry) nil)
                              #(create-session prompt-bufnr))
                            (if attach (attach prompt-bufnr map) true)))
                     (sessions opts)))]
  (set extension.sessions configured)
  (set extension.pterm configured))
