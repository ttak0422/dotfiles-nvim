local heirline = setmetatable({
	conditions = require("heirline.conditions"),
	utils = require("heirline.utils"),
	-- components = require("heirline-components.all"),
}, {
	__index = require("heirline"),
})

local function get_colors()
	return {
		fg = heirline.utils.get_highlight("Normal").fg,
		bg = heirline.utils.get_highlight("Normal").bg,
		red = heirline.utils.get_highlight("SpellBad").fg,
		blue = heirline.utils.get_highlight("SpellCap").fg,
		diag_warn = heirline.utils.get_highlight("DiagnosticWarn").fg,
		diag_error = heirline.utils.get_highlight("DiagnosticError").fg,
		diag_hint = heirline.utils.get_highlight("DiagnosticHint").fg,
		diag_info = heirline.utils.get_highlight("DiagnosticInfo").fg,
		git_del = heirline.utils.get_highlight("DiffDelete").fg,
		git_add = heirline.utils.get_highlight("DiffAdd").fg,
		git_change = heirline.utils.get_highlight("DiffChange").fg,
	}
end

vim.api.nvim_create_augroup("Heirline", { clear = true })
vim.api.nvim_create_autocmd("ColorScheme", {
	callback = function()
		heirline.utils.on_colorscheme(get_colors())
	end,
	group = "Heirline",
})

-- parameters
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
local git
do
	local branch = {
		provider = function(self)
			return " " .. icons.git_branch .. " " .. self.git_status.head
		end,
		hl = { bold = true },
	}
	local changes = {
		{
			provider = function(self)
				return " " .. icons.git_add .. " " .. (self.git_status.added or 0)
			end,
			hl = function(self)
				return { fg = vim.g["terminal_color_9"] or heirline.utils.get_highlight("DiffAdd").bg }
			end,
		},
		{
			provider = function(self)
				return " " .. icons.git_change .. " " .. (self.git_status.changed or 0)
			end,
			hl = function(self)
				return { fg = vim.g["terminal_color_12"] or heirline.utils.get_highlight("DiffChange").bg }
			end,
		},
		{
			provider = function(self)
				return " " .. icons.git_del .. " " .. (self.git_status.removed or 0)
			end,
			hl = function(self)
				return { fg = vim.g["terminal_color_10"] or heirline.utils.get_highlight("DiffDelete").bg }
			end,
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
		return self.root .. " "
	end,
	update = { "DirChanged" },
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
		common.align,
		-- center
		help_name,
		common.align,
		-- right
		{
			provider = function()
				return " " .. icons.document .. " " .. string.upper(vim.bo.filetype) .. " "
			end,
			update = { "WinNew", "WinClosed", "BufEnter" },
		},
	}
end

local terminal_status
do
	local name = {
		provider = "  terminal ",
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
		common.align,
		name,
	}
end

local default_status
do
	default_status = {
		-- left
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
		common.bar,
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
		hl = { fg = "fg", bg = "bg" },
		special_status,
		terminal_status,
		default_status,
	},
	opts = {
		colors = get_colors(),
	},
})
