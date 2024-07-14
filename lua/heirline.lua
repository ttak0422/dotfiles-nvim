local heirline = setmetatable({
	conditions = require("heirline.conditions"),
	utils = require("heirline.utils"),
	-- components = require("heirline-components.all"),
}, {
	__index = require("heirline"),
})

-- parameters
local colors
do
	local C = require("morimo.colors")
	colors = {
		fg = C.fg,
		bg = C.bg0,
		red = C.red,
		green = C.green,
		blue = C.blue,
		grey = C.grey0,
		orange = C.orange,
		purple = C.purple,
		cyan = C.cyan,
		git_add = C.lightGreen,
		git_change = C.lightBlue,
		git_del = C.lightRed,
	}
end
local mode_colors = {
	n = "red",
	no = "red",
	nov = "red",
	noV = "red",
	["no\022"] = "red",
	niI = "red",
	niR = "red",
	niV = "red",
	nt = "red",
	v = "blue",
	vs = "blue",
	V = "blue",
	Vs = "blue",
	["\022"] = "blue",
	["\022s"] = "blue",
	s = "purple",
	S = "purple",
	["\019"] = "purple",
	i = "green",
	ic = "green",
	ix = "green",
	R = "orange",
	Rc = "orange",
	Rx = "orange",
	Rv = "orange",
	Rvc = "orange",
	Rvx = "orange",
	c = "red",
	ct = "red",
	cv = "red",
	ce = "red",
	r = "red",
	rm = "red",
	["r?"] = "red",
	["!"] = "red",
	t = "red",
}
local icons = {
	vim = "",
	lock = "",
	fill = "█",
	terminal = "",
	document = "",
	git_branch = "",
	git_add = "",
	git_change = "",
	git_del = "",
	warn = "",
	error = "",
}

-- common components
local common = {
	align = { provider = "%=" },
	space = { provider = " " },
	bar = { provider = " | " },
}

-- components
local mode_symbol
do
	local symbol
	do
		local readonly_symbol = {
			condition = function()
				return vim.bo.readonly or not vim.bo.modifiable
			end,
			provider = icons.lock,
			hl = { fg = colors.bg },
		}
		local vim_symbol = {
			provider = icons.vim,
			hl = { fg = colors.bg },
		}
		symbol = {
			fallthrough = false,
			readonly_symbol,
			vim_symbol,
		}
	end
	mode_symbol = {
		init = function(self)
			self.mode = vim.fn.mode(1)
		end,
		update = { "ModeChanged" },
		heirline.utils.surround({ icons.fill, icons.fill }, function(self)
			return mode_colors[self.mode:sub(1, 1)]
		end, symbol),
	}
end

local git
do
	local branch = {
		provider = function(self)
			return icons.git_branch .. " " .. self.git_status.head
		end,
	}
	local changes = {
		{
			provider = function(self)
				return " " .. icons.git_add .. " " .. (self.git_status.added or 0)
			end,
			hl = { fg = colors.git_add },
		},
		{
			provider = function(self)
				return " " .. icons.git_change .. " " .. (self.git_status.changed or 0)
			end,
			hl = { fg = colors.git_change },
		},
		{
			provider = function(self)
				return " " .. icons.git_del .. " " .. (self.git_status.removed or 0)
			end,
			hl = { fg = colors.git_del },
		},
	}
	local active = {
		condition = heirline.conditions.is_git_repo,
		init = function(self)
			self.git_status = vim.b.gitsigns_status_dict
		end,
		branch,
		changes,
	}
	local inactive = {
		{
			provider = " ------",
		},
		{
			rovider = "  -  -  -",
		},
	}
	git = {
		fallthrough = false,
		update = { "User", pattern = "GitSignsUpdate" },
		active,
		inactive,
	}
end

local diagnostics
do
	local active = {
		condition = heirline.conditions.has_diagnostics,
		init = function(self)
			self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
			self.warns = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
		end,
		provider = function(self)
			return icons.error .. " " .. self.errors .. " " .. icons.warn .. " " .. self.warns
		end,
	}
	local inactive = {
		provider = icons.error .. " - " .. icons.warn .. " -",
	}
	diagnostics = {
		fallthrough = false,
		active,
		inactive,
	}
end

local harpoon = {
	provider = function()
		return require("harpoonline").format()
	end,
}

local lsp = {
	provider = require("lsp-progress").progress,
	update = {
		"User",
		pattern = "LspProgressStatusUpdated",
		callback = vim.schedule_wrap(function()
			vim.cmd("redrawstatus")
		end),
	},
}

local ruler = {
	provider = "%7(%l,%c%)",
}

local file_properties
do
	local encoding = {
		condition = function(self)
			self.encoding = ((vim.bo.fileencoding ~= "") and vim.bo.fileencoding) or vim.o.encoding or ""
			return self.encoding
		end,
		provider = function(self)
			return string.upper(self.encoding)
		end,
	}
	local format = {
		condition = function(self)
			self.format = vim.bo.fileformat
			return self.format
		end,
		provider = function(self)
			return (self.format_label[self.format] or self.format)
		end,
		static = {
			format_label = {
				dos = "CRLF",
				mac = "CR",
				unix = "LF",
			},
		},
	}
	file_properties = {
		update = {
			"WinNew",
			"WinClosed",
			"BufEnter",
		},
		encoding,
		common.space,
		format,
	}
end

local working_dir = {
	init = function(self)
		local cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
		self.root = self.alias[cwd] or cwd
	end,
	provider = function(self)
		return "   " .. self.root .. " "
	end,
	update = { "DirChanged" },
	hl = { fg = colors.bg, bg = colors.orange },
	static = {
		alias = {
			[""] = "ROOT",
		},
	},
}

-- status lines
local special_status
do
	local help_name = {
		condition = function()
			return vim.bo.buftype == "help"
		end,
		provider = function()
			return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t")
		end,
		hl = { fg = colors.fg },
	}
	special_status = {
		condition = function()
			return heirline.conditions.buffer_matches({
				buftype = { "nofile", "prompt", "help", "quickfix" },
				filetype = {
					"^git.*",
					"fugative",
				},
			})
		end,
		-- left
		mode_symbol,
		common.align,
		-- center
		help_name,
		common.align,
		-- right
		{
			provider = function()
				return " " .. icons.document .. " " .. string.upper(vim.bo.filetype) .. " "
			end,
			hl = { fg = colors.bg, bg = colors.blue },
			update = { "WinNew", "WinClosed", "BufEnter" },
		},
	}
end

local terminal_status
do
	local symbol = heirline.utils.surround({ icons.fill, icons.fill }, function()
		return colors.red
	end, {
		provider = icons.terminal,
		hl = { fg = colors.bg },
	})
	local name = {
		provider = function()
			local name, _ = vim.api.nvim_buf_get_name(0):gsub(".*:", "")
			return " " .. name .. " "
		end,
		hl = { fg = colors.bg, bg = colors.red },
		update = {
			"WinNew",
			"WinClosed",
			"BufEnter",
		},
	}

	terminal_status = {
		condition = function()
			return heirline.conditions.buffer_matches({
				buftype = { "terminal" },
			})
		end,
		symbol,
		common.align,
		name,
	}
end

local default_status
do
	default_status = {
		-- left
		mode_symbol,
		common.space,
		git,
		common.bar,
		diagnostics,
		common.bar,
		harpoon,
		common.space,
		lsp,
		common.align,
		-- right
		ruler,
		common.bar,
		file_properties,
		common.space,
		working_dir,
	}
end

-- tabline
local tabline
do
	local tree = {
		condition = function(self)
			self.win = vim.api.nvim_tabpage_list_wins(0)[1]
			local bufnr = vim.api.nvim_win_get_buf(self.win)
			local ft = vim.bo[bufnr].filetype
			return ft == "NvimTree"
		end,
		provider = function(self)
			local width = vim.api.nvim_win_get_width(self.win)
			local pad_size = math.ceil((width - #self.title) / 2)
			local pad = string.rep(" ", pad_size)
			return pad .. self.title .. pad
		end,
		hl = function(self)
			if vim.api.nvim_get_current_win == self.win then
				return "TablineSel"
			end
			return "Tabline"
		end,
		static = {
			title = "NvimTree",
		},
	}

	local buffer_list
	do
		local get_fg_hl = function(is_active)
			return is_active and colors.bg or colors.fg
		end
		local get_bg_hl = function(is_active)
			return is_active and colors.orange or colors.bg
		end
		local file_name = {
			provider = function(self)
				local bufname = vim.api.nvim_buf_get_name(self.bufnr) or ""
				if bufname == "" then
					return "[No Name]"
				end
				return vim.fn.fnamemodify(bufname, ":t")
			end,
			hl = function(self)
				return {
					bold = self.is_active or self.is_visible,
					fg = get_fg_hl(self.is_active),
					bg = get_bg_hl(self.is_active),
				}
			end,
		}
		local file_flag = {
			condition = function(self)
				return vim.api.nvim_buf_get_option(self.bufnr, "modified")
			end,
			provider = " [+]",
			hl = function(self)
				return {
					fg = get_fg_hl(self.is_active),
					bg = get_bg_hl(self.is_active),
				}
			end,
		}
		local file = heirline.utils.surround({ icons.fill, icons.fill }, function(self)
			return get_bg_hl(self.is_active)
		end, {
			{
				init = function(self)
					self.filename = vim.api.nvim_buf_get_name(self.bufnr)
				end,
				hl = function(self)
					return self.is_active and "TablineSel" or "Tabline"
				end,
				file_name,
				file_flag,
			},
		})
		buffer_list = heirline.utils.make_buflist(file, {
			provider = "<",
			hl = {
				fg = colors.grey,
			},
		}, {
			provider = ">",
			hl = {
				fh = colors.grey,
			},
		})
	end

	local tabpage = {
		provider = function(self)
			return " %" .. self.tabnr .. "T" .. self.tabpage .. " %T"
		end,
		hl = function(self)
			return self.is_active and "TabLineSel" or "TabLine"
		end,
	}
	local tab_list = {
		condition = function()
			return #vim.api.nvim_list_tabpages() > 1
		end,
		common.align,
		heirline.utils.make_tablist(tabpage),
	}
	tabline = {
		tree,
		buffer_list,
		tab_list,
	}
end

-- tablineを常に表示する
vim.o.showtabline = 2
-- ステータスラインを集約
vim.o.laststatus = 3

heirline.setup({
	statusline = {
		fallthrough = false,
		hl = { fg = colors.fg, bg = colors.bg, bold = true },
		special_status,
		terminal_status,
		default_status,
	},
	tabline = tabline,
	opts = {
		colors = colors,
	},
})
