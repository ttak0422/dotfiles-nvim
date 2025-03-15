(let [cachePath (vim.fn.stdpath :cache)
      opts {; ;; 日本語の優先度を上げる
            ; :helplang "ja,en"
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
            :winheight 1}]
  (each [k v (pairs opts)]
    (tset vim.o k v))
  (vim.opt.fillchars:append {:eob " "
                             :fold " "
                             :foldopen "▾"
                             :foldsep " "
                             :foldclose "▸"}))

(let [opts {:noremap true :silent true}
      desc (fn [d] {:noremap true :silent true :desc d})
      cmd (fn [c] (.. :<cmd> c :<cr>))
      lcmd (fn [c] (cmd (.. "lua " c)))
      toggle (fn [id]
               (fn []
                 ((. (require :toggler) :toggle) id)))]
  (each [_ k (ipairs [;; movement
                      [:gpd
                       (lcmd "require('goto-preview').goto_preview_definition()")
                       (desc "󰩊 definition")]
                      [:gpi
                       (lcmd "require('goto-preview').goto_preview_implementation()")
                       (desc "󰩊 implementation")]
                      [:gpr
                       (lcmd "require('goto-preview').goto_preview_references()")
                       (desc "󰩊 references")]
                      [:gP
                       (lcmd "require('goto-preview').close_all_win()")
                       (desc "󰩊 close all")]
                      [:gb (lcmd "require('dropbar.api').pick()") (desc :pick)]
                      ;; debug
                      [:<F5>
                       (lcmd "require('dap').continue()")
                       (desc " continue")]
                      [:<F10>
                       (lcmd "require('dap').step_over()")
                       (desc " step over")]
                      [:<F11>
                       (lcmd "require('dap').step_into()")
                       (desc " step into")]
                      [:<F12>
                       (lcmd "require('dap').step_out()")
                       (desc " step out")]
                      [:<LocalLeader>db
                       (lcmd "require('dap').toggle_breakpoint()")
                       (desc " toggle breakpoint")]
                      [:<LocalLeader>dB
                       (fn []
                         (let [dap (require :dap)]
                           (dap.set_breakpoint (vim.fn.input "Breakpoint condition: "))))
                       (desc " set breakpoint with condition")]
                      [:<LocalLeader>dr
                       (lcmd "require('dap').repl.toggle()")
                       (desc " toggle repl")]
                      [:<LocalLeader>dl
                       (lcmd "require('dap').run_last()")
                       (desc " run last")]
                      [:<LocalLeader>dd (toggle :dapui) (desc " toggle ui")]
                      [:<Leader>O (cmd :Other)]])]
    (vim.keymap.set :n (. k 1) (. k 2) (or (. k 3) opts)))
  ;; leader
  (each [_ k (ipairs [;; translate
                      [:T (cmd "Translate JA")]
                      ;; debug
                      [:<LocalLeader>K
                       (lcmd "require('dapui').eval()")
                       (desc "dap evaluate expression")]
                      ;; copilot caht
                      [:<Leader>ta (cmd :CopilotChat)]])]
    (vim.keymap.set :v (. k 1) (. k 2) (or (. k 3) opts)))
  ;; local leader
  (each [_ k (ipairs [[:tT (cmd :Neotest) (desc " run test (file)")]
                      [:tt (cmd :NeotestNearest) (desc " run test (unit)")]
                      [:to
                       (toggle :neotest-output)
                       (desc " show test results")]
                      [:tO
                       (toggle :neotest-summary)
                       (desc " show test tree")]
                      [:tK (cmd :NeotestOpenOutput) (desc " hover (test)")]])]
    (vim.keymap.set :n (.. :<LocalLeader> (. k 1)) (. k 2) (or (. k 3) opts)))
  (each [_ k (ipairs [[[:n :x]
                       :gs
                       (lcmd "require('reacher').start()")
                       (desc " search (window)")]
                      [[:n :x]
                       :gS
                       (lcmd "require('reacher').start_multiple()")
                       (desc " search (editor)")]])]
    (vim.keymap.set (. k 1) (. k 2) (. k 3) (or (. k 4) opts))))
