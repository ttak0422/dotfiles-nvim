(local diffview (require :diffview))

(diffview.setup {:icons {:folder_closed "" :folder_open ""}
                 :signs {:fold_closed "▸" :fold_open "▾" :done "✓"}})
