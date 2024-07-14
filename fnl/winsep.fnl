(local no_exec_files (dofile args.exclude_ft_path))

(let [M (require :colorful-winsep)
      ;; U (require :colorful-winsep.utils)
      symbols ["━" "┃" "┏" "┓" "┗" "┛"]]
  (M.setup {:smooth false : symbols : no_exec_files}))
