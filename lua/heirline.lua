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

-- local harpoon = {
-- 	provider = function()
-- 		return require("harpoonline").format()
-- 	end,
-- }

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
		-- common.bar,
		-- harpoon,
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
	opts = {
		colors = colors,
	},
})
