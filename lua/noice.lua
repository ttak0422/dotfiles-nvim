require("noice").setup({
	cmdline = {
		enabled = true,
		view = "cmdline",
		opts = {},
		format = {
			cmdline = { pattern = "^:", icon = "", lang = "vim" },
			search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
			search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
			filter = { pattern = "^:%s*!", icon = "$", lang = "bash" },
			lua = { pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" }, icon = "", lang = "lua" },
			help = { pattern = "^:%s*he?l?p?%s+", icon = "?" },
			input = { view = "cmdline_input", icon = "󰥻 " },
		},
	},

	messages = {
		enabled = true,
		view = "notify",
		view_error = "notify",
		view_warn = "notify",
		view_history = "messages",
		view_search = "virtualtext",
	},

	popupmenu = {
		enabled = true,
		backend = "nui",
		kind_icons = {},
	},

	redirect = {
		view = "popup",
		filter = { event = "msg_show" },
	},

	commands = {
		history = {
			view = "split",
			opts = { enter = true, format = "details" },
			filter = {
				any = {
					{ event = "notify" },
					{ error = true },
					{ warning = true },
					{ event = "msg_show", kind = { "" } },
					{ event = "lsp", kind = "message" },
				},
			},
		},
		last = {
			view = "popup",
			opts = { enter = true, format = "details" },
			filter = {
				any = {
					{ event = "notify" },
					{ error = true },
					{ warning = true },
					{ event = "msg_show", kind = { "" } },
					{ event = "lsp", kind = "message" },
				},
			},
			filter_opts = { count = 1 },
		},
		errors = {
			view = "popup",
			opts = { enter = true, format = "details" },
			filter = { error = true },
			filter_opts = { reverse = true },
		},
		all = {
			view = "split",
			opts = { enter = true, format = "details" },
			filter = {},
		},
	},

	notify = {
		enabled = true,
		view = "notify",
	},

	lsp = {
		progress = { enabled = false },
		signature = { enabled = false },
		message = {
			enabled = true,
			view = "notify",
			opts = {},
		},
		hover = {
			enabled = true,
			silent = true,
			view = nil, -- use documentation
			opts = {},
		},
		documentation = {
			view = "hover",
			opts = {
				lang = "markdown",
				replace = true,
				render = "plain",
				format = { "{message}" },
				win_options = { concealcursor = "n", conceallevel = 3 },
			},
		},
		override = {
			["vim.lsp.util.convert_input_to_markdown_lines"] = true,
			["vim.lsp.util.stylize_markdown"] = true,
		},
	},

	markdown = {
		hover = {
			["|(%S-)|"] = vim.cmd.help,
			["%[.-%]%((%S-)%)"] = require("noice.util").open,
		},
		highlights = {
			["|%S-|"] = "@text.reference",
			["@%S+"] = "@parameter",
			["^%s*(Parameters:)"] = "@text.title",
			["^%s*(Return:)"] = "@text.title",
			["^%s*(See also:)"] = "@text.title",
			["{%S-}"] = "@parameter",
		},
	},

	health = { checker = true },

	presets = {
		bottom_search = true,
		command_palette = false,
		long_message_to_split = false,
		inc_rename = false,
		lsp_doc_border = false,
	},
	throttle = 1000 / 30, -- default
	views = {
		notify = {
			backend = { "snacks", "notify" },
			fallback = "mini",
			format = "notify",
			replace = false,
			merge = false,
		},
	},
	routes = {
		{
			filter = {
				event = "msg_show",
				kind = "search_count",
			},
			opts = { skip = true },
		},
		{
			filter = {
				event = "msg_show",
				any = {
					-- `%dL, %dB`
					{ find = "L, " },
					{ find = "written" },
					{ find = "追加しました;" },
					{ find = "変更しました;" },
					{ find = "削除しました;" },
					{ find = "既に一番新しい変更です" },
					{ find = "既に一番古い変更です" },
					-- WIP: ignore skkeleton warning
					{ find = "can't write userDictionary" },
				},
			},
			opts = { skip = true },
		},
	},
	status = {},
	format = {},
})
