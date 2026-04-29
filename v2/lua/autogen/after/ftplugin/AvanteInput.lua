-- [nfnl] v2/fnl/after/ftplugin/AvanteInput.fnl
local opts = {buf = 0, silent = true}
return vim.keymap.set("n", "<Leader>p", "<Cmd>PasteImage<CR>", opts)
