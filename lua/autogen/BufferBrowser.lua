-- [nfnl] Compiled from fnl/BufferBrowser.fnl by https://github.com/Olical/nfnl, do not edit.
local filetype_filters = dofile(args.exclude_ft_path)
local M = require("buffer_browser")
return M.setup({filetype_filters = filetype_filters})
