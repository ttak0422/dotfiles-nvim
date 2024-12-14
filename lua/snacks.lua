require("snacks").setup({
	notifier = {
		icons = {
			error = " ",
			warn = " ",
			info = " ",
			debug = " ",
			trace = " ",
		},
		style = "compact",
	},
	bigfile = {
		size = 1.0 * 1024 * 1024,
		-- setup = function(ctx)
		-- 	vim.cmd([[NoMatchParen]])
		-- 	Snacks.util.wo(0, { foldmethod = "manual", statuscolumn = "", conceallevel = 0 })
		-- 	vim.b.minianimate_disable = true
		-- 	vim.schedule(function()
		-- 		vim.bo[ctx.buf].syntax = ctx.ft
		-- 	end)
		-- end,
	},
})
