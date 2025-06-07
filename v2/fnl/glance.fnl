(local glance (require :glance))

(local border {:enable true :top_char "━" :bottom_char "━"})
(local folds {:fold_closed "▸" :fold_open "▾" :folded true})

(glance.setup {: border : folds :use_trouble_qf true})
