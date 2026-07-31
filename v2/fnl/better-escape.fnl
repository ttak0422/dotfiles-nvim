(local be (require :better_escape))

;; :t の jk は1打目のjが子プロセスに届いてからDELで消される。claude等の入力欄を持つ
;; TUIなら無傷だが、jが移動コマンドのTUI(lazygit/less)では取り消しが効かず1行ずれる。
(be.setup {:default_mappings false
           :mappings {:i {:j {:k :<Esc>}}
                      :c {}
                      :t {:j {:k "<C-\\><C-n>"}}
                      :v {}
                      :s {}}})
