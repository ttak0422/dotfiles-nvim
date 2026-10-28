(local goto (require :goto-preview))

(goto.setup {:height 20
             :width 120
             ;; Above ordinary floats (50), below native completion (100).
             ;; Nested previews increment this value; cmp uses 1001.
             :zindex 90
             :default_mappings false
             :resizing_mappings false
             :border :single})
