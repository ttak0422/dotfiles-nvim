require("neo-zoom").setup({
	exclude_buftypes = {},
	winopts = {
		offset = {
			width = 180,
			height = 0.9,
		},
		border = "single",
	},
	presets = {
		{
			filetypes = { "dapui_.*", "dap-repl" },
			winopts = {
				offset = { top = 0.02, left = 0.26, width = 0.74, height = 0.6 },
			},
		},
	},
	callbacks = {
		function()
			vim.cmd([[
        hi link NeoZoomFloatBg Normal
        hi link NeoZoomFloatBorder Normal
        set winhl=Normal:NeoZoomFloatBg,FloatBorder:NeoZoomFloatBorder
      ]])
		end,
	},
})
