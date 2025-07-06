(local notify (require :notify))

(notify.setup {:timeout 2500
               :render :default
               :top_down false
               :stages :static
               :background_colour "#000000"})

(set vim.notify notify)
