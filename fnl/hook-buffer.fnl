(let [cachePath (vim.fn.stdpath :cache)
      opts {;; 日本語の優先度を上げる
            :helplang "ja,en"
            ;; マウス操作
            :mouse :a
            ;; 未保存のバッファ切り替えを許容
            :hidden true
            ;; 外部で更新されたファイルを自動再読み込み
            :autoread true
            ;; デフォルトモーションで移動時に日空白文字列に移動
            :startofline false
            ;; undofile
            :undofile true
            :undodir (.. cachePath :/undo)
            ;; swapfile
            :swapfile true
            :directory (.. cachePath :/swap)
            ;; backup
            :backup true
            ;; inodeの挙動変更
            :backupcopy :yes
            :backupdir (.. cachePath :/backup)
            ;; diffの挙動制御
            :diffopt "internal,filler,closeoff,vertical"
            ;; 分割の挙動を変更
            :splitright true
            :splitbelow true
            ;; ウィンドウ分割時にサイズを均等にしようとしない
            :equalalways false
            ;; カレントウィンドウの最小幅
            :winwidth 20
            ;; カレントウィンドウの最小高
            :winheight 1
            :foldcolumn :1
            :signcolumn :yes
            :number true
            :foldenable true
            :fillchars "eob: ,fold: ,foldopen:,foldsep: ,foldclose:"}]
  (each [k v (pairs opts)]
    (tset vim.o k v)))

(let [opts {:noremap true :silent true}
      desc (fn [d] {:noremap true :silent true :desc d})
      cmd (fn [c] (.. :<cmd> c :<cr>))
      lcmd (fn [c] (cmd (.. "lua " c)))
      N [;; movement
         [:gpd
          (lcmd "require('goto-preview').goto_preview_definition()")
          (desc "preview definition")]
         [:gpi
          (lcmd "require('goto-preview').goto_preview_implementation()")
          (desc "preview implementation")]
         [:gpr
          (lcmd "require('goto-preview').goto_preview_references()")
          (desc "preview references")]
         [:gP
          (lcmd "require('goto-preview').close_all_win()")
          (desc "close all preview")]
         [:gb (lcmd "require('dropbar.api').pick()") (desc :pick)]
         ;; debug
         [:<F5> (lcmd "require('dap').continue()") (desc :continue)]
         [:<F10> (lcmd "require('dap').step_over()") (desc "step over")]
         [:<F11> (lcmd "require('dap').step_into()") (desc "step into")]
         [:<F12> (lcmd "require('dap').step_out()") (desc "step out")]
         [:<LocalLeader>db
          (lcmd "require('dap').toggle_breakpoint()")
          (desc "dap toggle breakpoint")]
         [:<LocalLeader>dB
          (fn []
            (let [dap (require :dap)]
              (dap.set_breakpoint (vim.fn.input "Breakpoint condition: "))))
          (desc "dap set breakpoint with condition")]
         [:<LocalLeader>dr
          (lcmd "require('dap').repl.toggle()")
          (desc "dap toggle repl")]
         [:<LocalLeader>dl
          (lcmd "require('dap').run_last()")
          (desc "dap run last")]
         [:<LocalLeader>dd
          (fn []
            (let [dapui (require :dapui)]
              (dapui.toggle {:reset true})))
          (desc "dap toggle ui")]]
      V [;; debug
         [:<LocalLeader>K
          (lcmd "require('dapui').eval()")
          (desc "dap evaluate expression")]]
      OTHER [[[:n :x] :gs (lcmd "require('reacher').start()")]
             [[:n :x]
              :gS
              (lcmd "require('reacher').start_multiple()")
              (desc "search displayed")]
             [[:n :i :c :t] "¥" "\\"]]]
  (each [_ k (ipairs N)]
    (vim.keymap.set :n (. k 1) (. k 2) (or (. k 3) opts)))
  (each [_ k (ipairs V)]
    (vim.keymap.set :n (. k 1) (. k 2) (or (. k 3) opts)))
  (each [_ k (ipairs OTHER)]
    (vim.keymap.set (. k 1) (. k 2) (. k 3) (or (. k 4) opts))))
