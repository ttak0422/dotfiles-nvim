-- [nfnl] Compiled from fnl/lastplace-pre.fnl by https://github.com/Olical/nfnl, do not edit.
local ignore_filetype = dofile(args.exclude_ft_path)
local ignore_buftype = dofile(args.exclude_buf_ft_path)
vim.g.nvim_lastplace = {ignore_buftype = ignore_buftype, ignore_filetype = ignore_filetype, open_folds = true}
return nil
