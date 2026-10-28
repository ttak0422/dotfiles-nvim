;; <ESC>1回 → ノーマルモードに遷移、<ESC>2回 → ESCを入力
(vim.cmd "
tnoremap <ESC> <c-\\><c-n><Plug>(esc)
nnoremap <Plug>(esc)<ESC> i<ESC>
         ")

(var state {})
(var sync-input nil)
(local set-option vim.api.nvim_set_option_value)

(fn restore-winbars []
  (each [win value (pairs (or state.winbars {}))]
    (when (vim.api.nvim_win_is_valid win)
      (set-option :winbar value {: win}))))

(fn original-window [win]
  (let [zoom (. package.loaded :neo-zoom)]
    (or (and zoom zoom.zoom_book (. zoom.zoom_book win)) win)))

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
      (vim.schedule #(when (and (= (vim.api.nvim_get_current_win) win)
                               (= (vim.api.nvim_get_current_buf) buf))
                       (vim.cmd.startinsert))))))

(fn send-input []
  ;; 送信失敗や終了済み terminal では入力を破棄しない。
  (let [valid? (and state.term-buf (vim.api.nvim_buf_is_valid state.term-buf)
                   (= (terminal-channel state.term-buf) state.chan))
        text (.. (table.concat (vim.api.nvim_buf_get_lines state.buf 0 -1 false) "\n") "\r")
        (ok? err) (if valid?
                     (if (= text "\r") true (pcall vim.api.nvim_chan_send state.chan text))
                     (values false "terminal is unavailable"))]
    (when (not ok?)
      (vim.notify (.. "terminal input retained: " err) vim.log.levels.ERROR))
    ok?))

(fn close-input [send?]
  (sync-input)
  (when (or (not send?) (send-input))
    (let [buf state.buf
          win state.win
          term-buf state.term-buf
          term-win state.term-win
          term-cursor state.term-cursor]
      (restore-winbars)
      (when (and win (vim.api.nvim_win_is_valid win))
        (pcall vim.api.nvim_win_close win true))
      (when (and buf (vim.api.nvim_buf_is_valid buf))
        (pcall vim.api.nvim_buf_delete buf {:force true}))
      (set state {})
      (focus-terminal term-win term-buf term-cursor))))

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
  (sync-input)
  (when (and state.win (vim.api.nvim_win_is_valid state.win)
             (= (vim.api.nvim_get_current_win) state.win)
             (not (. (vim.api.nvim_win_get_config state.win) :hide)))
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
     ;; 背景 terminal の補助は zoom より下、zoom terminal の補助はその直上に置く。
     :zindex (+ (or (. (vim.api.nvim_win_get_config term-win) :zindex) 0) 1)
     :style :minimal
     :border :single
     :title " SKK input "
     :title_pos :center
     : width
     : height
     : row
     : col}))

(set sync-input
     (fn []
       (when (and state.win (vim.api.nvim_win_is_valid state.win))
         (let [zoom (. package.loaded :neo-zoom)
               wins (vim.api.nvim_tabpage_list_wins state.tab)
               owns? (fn [win]
                       (and win (vim.api.nvim_win_is_valid win)
                            (= (vim.api.nvim_win_get_buf win) state.term-buf)))]
           (var owner (if (owns? state.home-win) state.home-win
                          (when (owns? state.term-win) state.term-win)))
           (var zoom-win nil)
           (each [_ win (ipairs wins)]
             (when (and zoom zoom.zoom_book (. zoom.zoom_book win))
               (set zoom-win win)
               (when (and (owns? win)
                          (or (= win state.term-win)
                              (= (. zoom.zoom_book win) state.home-win)))
                 (set owner win))))
           (when (not= owner state.term-win)
             (restore-winbars))
           (set state.term-win owner)
           (let [hide? (or (not owner) (and zoom-win (not= owner zoom-win)))
                 config (if owner
                            (vim.api.nvim_win_call owner
                              #(input-float-config owner
                                 (math.max 10 (math.min 80 (- (vim.api.nvim_win_get_width owner) 4))) 5))
                            {:relative :editor :row 0 :col 0})]
             (set config.hide (not (not hide?)))
             (when owner
               (when (= (. state.winbars owner) nil)
                 (tset state.winbars owner (vim.api.nvim_get_option_value :winbar {:win owner :scope :local})))
               (set-option :winbar (if hide? (. state.winbars owner) "") {:win owner}))
             (vim.api.nvim_win_set_config state.win config)
             ;; 非表示の入力に focus を残すとカーソルも消える。
             (when (and hide? (= (vim.api.nvim_get_current_win) state.win))
               (var target (or zoom-win owner))
               (each [_ win (ipairs wins)]
                 (when (and (not target) (not= win state.win)
                            (= (. (vim.api.nvim_win_get_config win) :relative) ""))
                   (set target win)))
               (when target (vim.api.nvim_set_current_win target))))))
       (when (and state.win (not (vim.api.nvim_win_is_valid state.win)))
         (restore-winbars)
         (set state {}))))

;; NeoZoom は元 split の buffer を交換する。イベント完了後に所有先を解決する。
(var sync-pending? false)
(vim.api.nvim_create_autocmd [:WinEnter :BufWinEnter :WinClosed :BufWipeout :TabEnter]
  {:group (vim.api.nvim_create_augroup :TerminalSkkInput {:clear true})
   :callback (fn []
               (when (not sync-pending?)
                 (set sync-pending? true)
                 (vim.schedule (fn [] (set sync-pending? false) (sync-input)))))})

(fn open-input []
  (if (and state.win (vim.api.nvim_win_is_valid state.win))
      (do
        (when (and (not state.term-win)
                   (= (vim.api.nvim_get_current_tabpage) state.tab)
                   (= (vim.api.nvim_get_current_buf) state.term-buf))
          (set state.home-win (original-window (vim.api.nvim_get_current_win))))
        (sync-input)
        (if (. (vim.api.nvim_win_get_config state.win) :hide)
            (vim.notify "SKK input draft belongs to another terminal window" vim.log.levels.WARN)
            (do (vim.api.nvim_set_current_win state.win)
                (vim.schedule start-input))))
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
                          :home-win (original-window term-win)
                          :tab (vim.api.nvim_win_get_tabpage term-win)
                          :winbars {}
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
              (sync-input)
              (vim.api.nvim_buf_set_lines buf 0 -1 false [""])
              (set-input-keymaps buf)
              (vim.schedule start-input))))))

(vim.keymap.set :t :<C-g> open-input
                {:noremap true :silent true :desc "SKK input helper"})
