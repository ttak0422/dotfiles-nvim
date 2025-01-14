-- [nfnl] Compiled from fnl/winsep.fnl by https://github.com/Olical/nfnl, do not edit.
local no_exec_files = dofile(args.exclude_ft_path)
return require("colorful-winsep").setup({no_exec_files = no_exec_files, exponential_smoothing = false, smooth = false})
