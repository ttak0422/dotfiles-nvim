(local notify (require :notify))

(notify.setup {:timeout 2500
               :render :default
               :top_down true
               :stages :static
               :background_colour "#000000"})

(set vim.notify notify)
