;; <ESC>1回 → ノーマルモードに遷移、<ESC>2回 → ESCを入力
(vim.cmd "
tnoremap <ESC> <c-\\><c-n><Plug>(esc)
nnoremap <Plug>(esc)<ESC> i<ESC>
         ")

(var state {})
(local set-option vim.api.nvim_set_option_value)

(fn terminal-channel [buf]
  (let [(ok? chan) (pcall vim.api.nvim_buf_get_var buf :terminal_job_id)]
    (when (and ok? (= (type chan) :number))
      chan)))

(fn focus-terminal [win buf cursor]
  (when (and win (vim.api.nvim_win_is_valid win))
    (vim.api.nvim_set_current_win win)
    (when cursor
      (pcall vim.api.nvim_win_set_cursor win cursor))
    (when (and buf (vim.api.nvim_buf_is_valid buf)
               (= (. vim.bo buf :buftype) :terminal))
      (vim.schedule #(vim.cmd.startinsert)))))

(fn close-input [send?]
  (let [buf state.buf
        win state.win
        term-buf state.term-buf
        term-win state.term-win
        term-cursor state.term-cursor
        chan state.chan
        lines (if (and buf (vim.api.nvim_buf_is_valid buf))
                  (vim.api.nvim_buf_get_lines buf 0 -1 false)
                  [])]
    (when (and win (vim.api.nvim_win_is_valid win))
      (pcall vim.api.nvim_win_close win true))
    (when (and buf (vim.api.nvim_buf_is_valid buf))
      (pcall vim.api.nvim_buf_delete buf {:force true}))
    (when (and term-win (vim.api.nvim_win_is_valid term-win))
      (pcall vim.api.nvim_win_call term-win #(vim.cmd "setlocal winbar<")))
    (set state {})
    (when send?
      (let [text (.. (table.concat lines "\n") "\r")]
        (when (not= text "\r")
          (let [(ok? err) (pcall vim.api.nvim_chan_send chan text)]
            (when (not ok?)
              (vim.notify (.. "terminal input failed: " err)
                          vim.log.levels.ERROR))))))
    (focus-terminal term-win term-buf term-cursor)))

(fn accept-input []
  (close-input true))

(fn cancel-input []
  (close-input false))

(fn enable-skkeleton []
  (let [keys (vim.api.nvim_replace_termcodes "<Plug>(skkeleton-enable)" true
                                             false true)]
    (vim.api.nvim_feedkeys keys :m false)))

(fn set-input-keymaps [buf]
  (let [keymap-opts {:buffer buf :noremap true :nowait true :silent true}]
    ;; <Esc> は SKK のモード操作に使うため popup を閉じない。
    ;; 取消は <C-c>/<leader>q、確定は <C-s>。
    (vim.keymap.set :i :<C-c> cancel-input keymap-opts)
    (vim.keymap.set :n :<C-c> cancel-input keymap-opts)
    (vim.keymap.set :n :<leader>q cancel-input keymap-opts)
    (vim.keymap.set :n :<leader>Q cancel-input keymap-opts)
    (vim.keymap.set :n :<C-s> accept-input keymap-opts)
    (vim.keymap.set :i :<C-s> accept-input keymap-opts)))

(fn start-input []
  (when (and state.win (vim.api.nvim_win_is_valid state.win))
    (vim.api.nvim_set_current_win state.win)
    (vim.cmd.startinsert)
    (enable-skkeleton)))

(fn input-float-config [term-win width height]
  ;; `winline`/`wincol` はウィンドウ相対の画面位置を返す (1-indexed)。
  ;; `nvim_win_get_cursor` のバッファ行はスクロールバックで巨大になり
  ;; `relative=win` の座標として使うとカーソルから大きく外れるため使わない。
  (let [cursor-row (- (vim.fn.winline) 1)
        cursor-col (- (vim.fn.wincol) 1)
        win-height (vim.api.nvim_win_get_height term-win)
        win-width (vim.api.nvim_win_get_width term-win)
        border-size 2
        row (if (<= (+ cursor-row 1 height border-size) win-height)
                (+ cursor-row 1)
                (math.max 0 (- cursor-row height border-size)))
        col (math.min cursor-col (math.max 0 (- win-width width border-size)))]
    {:relative :win
     :win term-win
     :style :minimal
     :border :single
     :title " SKK input "
     :title_pos :center
     : width
     : height
     : row
     : col}))

(fn open-input []
  (if (and state.win (vim.api.nvim_win_is_valid state.win))
      (do
        (vim.api.nvim_set_current_win state.win)
        (vim.schedule start-input))
      (let [term-buf (vim.api.nvim_get_current_buf)
            term-win (vim.api.nvim_get_current_win)
            term-cursor (vim.api.nvim_win_get_cursor term-win)
            chan (terminal-channel term-buf)]
        (if (not chan)
            (vim.notify "Terminal SKK input is only available in terminal buffers"
                        vim.log.levels.WARN)
            (let [width (math.max 10
                                  (math.min 80
                                            (- (vim.api.nvim_win_get_width term-win)
                                               4)))
                  height 5
                  buf (vim.api.nvim_create_buf false true)
                  win (vim.api.nvim_open_win buf true
                                             (input-float-config term-win width
                                                                 height))]
              (set state {: buf
                          : win
                          : term-buf
                          : term-win
                          : term-cursor
                          : chan})
              (each [name value (pairs {:bufhidden :wipe
                                        :filetype :skk-terminal-input})]
                (set-option name value {: buf}))
              (vim.api.nvim_buf_set_name buf (.. "skk-terminal-input://" buf))
              (each [name value (pairs {:number false
                                        :relativenumber false
                                        :signcolumn :no
                                        :foldcolumn :0
                                        :wrap false
                                        :winbar ""})]
                (set-option name value {: win}))
              (set-option :winbar "" {:win term-win})
              (vim.api.nvim_buf_set_lines buf 0 -1 false [""])
              (set-input-keymaps buf)
              (vim.schedule start-input))))))

(vim.keymap.set :t :<C-g> open-input
                {:noremap true :silent true :desc "SKK input helper"})
