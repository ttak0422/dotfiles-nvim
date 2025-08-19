-- vim configurations
local cmdheight = 0
vim.o.showtabline = 2
vim.o.laststatus = 3
vim.o.cmdheight = cmdheight

vim.api.nvim_create_autocmd("VimResized", {
  callback = function()
    vim.o.cmdheight = cmdheight
  end,
})

-- heirline configurations
local heirline = require("heirline")
local utils = require("heirline.utils")
local conditions = require("heirline.conditions")

local function get_colors()
  return {
    fg = utils.get_highlight("Normal").fg,
    bg = utils.get_highlight("Normal").bg,
    red = utils.get_highlight("SpellBad").fg,
    blue = utils.get_highlight("SpellCap").fg,
    diag_warn = utils.get_highlight("DiagnosticWarn").fg,
    diag_error = utils.get_highlight("DiagnosticError").fg,
    diag_hint = utils.get_highlight("DiagnosticHint").fg,
    diag_info = utils.get_highlight("DiagnosticInfo").fg,
    git_del = utils.get_highlight("DiffDelete").fg,
    git_add = utils.get_highlight("DiffAdd").fg,
    git_change = utils.get_highlight("DiffChange").fg,
  }
end

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    utils.on_colorscheme(get_colors())
  end,
})

-- components
local align = { provider = "%=" }
local space = { provider = " " }
local bar = { provider = "  " }

local symbol = { provider = "" }

local git
do
  local changes = {
    {
      init = function(self)
        self.count = self.git_status.added or 0
        self.show = self.count > 0
      end,
      provider = function(self)
        return self.show and "  " .. self.count or ""
      end,
      hl = function(self)
        return { fg = self.show and vim.g["terminal_color_10"] or "fg" }
      end,
    },
    {
      init = function(self)
        self.count = self.git_status.changed or 0
        self.show = self.count > 0
      end,
      provider = function(self)
        return self.show and "  " .. self.count or ""
      end,
      hl = function(self)
        return { fg = self.show and vim.g["terminal_color_12"] or "fg" }
      end,
    },
    {
      init = function(self)
        self.count = self.git_status.removed or 0
        self.show = self.count > 0
      end,
      provider = function(self)
        return self.show and "  " .. self.count or ""
      end,
      hl = function(self)
        return { fg = self.show and vim.g["terminal_color_9"] or "fg" }
      end,
    },
  }
  local active = {
    condition = conditions.is_git_repo,
    init = function(self)
      self.git_status = vim.b.gitsigns_status_dict
    end,
    changes,
  }
  local inactive = {
    provider = "",
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
  local ds = {
    {
      init = function(self)
        self.show = self.errors > 0
      end,
      provider = function(self)
        return self.show and "  " .. self.errors or ""
      end,
      hl = function(self)
        return { fg = self.show and vim.g["terminal_color_1"] or "fg" }
      end,
    },
    {
      init = function(self)
        self.show = self.warns > 0
      end,
      provider = function(self)
        return self.show and "  " .. self.warns or ""
      end,
      hl = function(self)
        return { fg = self.show and vim.g["terminal_color_3"] or "fg" }
      end,
    },
  }
  local active = {
    condition = conditions.has_diagnostics,
    init = function(self)
      self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
      self.warns = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
    end,
    ds,
  }
  local inactive = {
    provider = "",
  }
  diagnostics = {
    fallthrough = false,
    active,
    inactive,
  }
end

-- local lsp = {
-- 	provider = function()
-- 		return require("lsp-progress").progress({ max_size = 100 })
-- 	end,
-- 	update = {
-- 		"User",
-- 		pattern = "LspProgressStatusUpdated",
-- 		callback = vim.schedule_wrap(function()
-- 			vim.cmd("redrawstatus")
-- 		end),
-- 	},
-- }

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
    static = { format_label = { dos = "CRLF", mac = "CR", unix = "LF" } },
  }
  file_properties = {
    update = { "WinNew", "WinClosed", "BufEnter" },
    encoding,
    space,
    format,
  }
end

local working_dir
do
  local branch = {
    condition = conditions.is_git_repo,
    provider = function(self)
      return "(" .. self.git_status.head .. ")"
    end,
    init = function(self)
      self.git_status = vim.b.gitsigns_status_dict
    end,
    update = { "User", pattern = "GitSignsUpdate" },
  }
  local dir_name = {
    init = function(self)
      local cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
      self.root = self.alias[cwd] or cwd
    end,
    provider = function(self)
      return self.root
    end,
    update = { "DirChanged" },
    static = { alias = { [""] = "ROOT" } },
  }
  working_dir = {
    dir_name,
    space,
    branch,
  }
end

-- statuslines
local s_special = {
  condition = function()
    return conditions.buffer_matches({
      buftype = { "nofile", "prompt", "help", "quickfix" },
      filetype = { "^git.*" },
    })
  end,
  -- left
  align,
  -- center
  {
    -- show help name if available
    condition = function()
      return vim.bo.buftype == "help"
    end,
    provider = function()
      return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t:r")
    end,
  },
  align,
  -- right
  {
    provider = function()
      return "  " .. string.upper(vim.bo.filetype) .. " "
    end,
    update = { "WinNew", "WinClosed", "BufEnter" },
  },
}

local s_terminal = {
  condition = function()
    return conditions.buffer_matches({
      buftype = { "terminal" },
    })
  end,
  align,
  {
    provider = "  terminal ",
    update = {
      "WinNew",
      "WinClosed",
      "BufEnter",
    },
  },
}

local s_default = {
  -- left
  -- symbol,
  git,
  diagnostics,
  space,
  -- lsp,
  align,
  -- right
  ruler,
  bar,
  -- file_properties,
  -- bar,
  working_dir,
}

-- setup
heirline.setup({
  opts = {
    colors = get_colors(),
  },
  statusline = {
    fallthrough = false,
    hl = { fg = "fg", bg = "bg" },
    s_special,
    s_terminal,
    s_default,
  },
})
