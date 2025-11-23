-- vim configurations
local cmdheight = 0
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

local page = {
  fallthrough = false,
  update = { "TabEnter" },
  {
    condition = function()
      return #vim.api.nvim_list_tabpages() > 1
    end,
    provider = function()
      return vim.fn.tabpagenr() .. "  "
    end,
  },
}

local statusline = {
  hl = { fg = "fg", bg = "bg" },
  -- left
  space,
  page,
  working_dir,
  git,
  diagnostics,
  space,
  align,
  -- right
}

local indicator
do
  local mod = {
    fallthrough = false,
    {
      condition = function(self)
        return vim.api.nvim_get_option_value("modified", { buf = self.bufnr })
      end,
      provider = " ",
      update = { "BufModifiedSet" },
    },
    { provider = "  " },
  }
  indicator = {
    mod,
  }
end

local file = {
  init = function(self)
    local name = vim.api.nvim_buf_get_name(0)
    local root = vim.fs.root(".", { ".git" })
    local buf_name = root and vim.fn.fnamemodify(name, ":." .. root) or name
    self.filename = vim.fn.fnamemodify(buf_name, ":t")
    self.path = vim.fn.fnamemodify(buf_name, ":h")
  end,
  {
    provider = function(self)
      return self.filename
    end,
    hl = utils.get_highlight("Title"),
  },
  { provider = " " },
  {
    provider = function(self)
      return self.path
    end,
    hl = utils.get_highlight("WinBar"),
  },
  update = { "WinNew", "BufEnter" },
}

local ruler = {
  provider = "%l,%c",
  hl = utils.get_highlight("WinBar"),
  update = "CursorMoved",
}

local winbar = {
  -- left
  indicator,
  file,
  space,
  align,
  -- right
  ruler,
  space,
}

-- setup
heirline.setup({
  statusline = statusline,
  winbar = winbar,
  opts = {
    colors = get_colors(),
    disable_winbar_cb = function(args)
      return conditions.buffer_matches({
        buftype = { "nofile", "prompt", "help", "quickfix" },
        filetype = { "^git.*", "Trouble" },
      }, args.buf)
    end,
  },
})
