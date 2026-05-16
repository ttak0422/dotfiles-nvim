(local komado (require :komado))
(local utils (require :komado.utils))
(local Line (. (require :komado.dsl) :Line))

(local Spacer (Line {:provider ""}))
(local Separator (utils.separator "─" :Comment))

(local Header [(Line [{:provider "■ komado "}]) Separator])

(komado.setup {:window {:position :left :size {:ratio 0.3 :min 38 :max 80}}
               :mappings {:q #(komado.close) :r #(komado.redraw)}
               :root [Header Spacer]})

(vim.api.nvim_create_user_command :KomadoToggle #(komado.toggle) {})
