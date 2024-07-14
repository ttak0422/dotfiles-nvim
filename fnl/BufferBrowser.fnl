(local filetype_filters (dofile args.exclude_ft_path))
(let [M (require :buffer_browser)]
  (M.setup {: filetype_filters}))
