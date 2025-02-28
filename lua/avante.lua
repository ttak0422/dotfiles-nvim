pcall(dofile, vim.env.HOME .. "/.config/nvim/avante.lua")

require("avante_lib").load()
require("avante").setup({
  provider = "copilot",
  auto_suggestions_provider = "claude",
  dual_boost = { enabled = false },
  hints = { enabled = true },
  behaviour = {
    auto_suggestion = false,
    auto_set_highlight_group = true,
    auto_set_keymaps = true,
    auto_apply_diff_after_generation = false, support_paste_from_clipboard = false, minimize_diff = true,
  },
  mappings = {
    diff = {
      ours = "co",
      theirs = "ct",
      all_theirs = "ca",
      both = "cb",
      cursor = "cc",
      next = "]x",
      prev = "[x",
    },
    suggestion = {
      accept = "<M-l>",
      next = "<M-]>",
      prev = "<M-[>",
      dismiss = "<C-]>",
    },
    jump = {
      next = "]]",
      prev = "[[",
    },
    submit = {
      normal = "<CR>",
      insert = "<C-s>",
    },
    sidebar = {
      apply_all = "A",
      apply_cursor = "a",
      switch_windows = "<Tab>",
      reverse_switch_windows = "<S-Tab>",
    },
  },
  windows = {
    ---@type "right" | "left" | "top" | "bottom"
    position = "right",
    wrap = true,
    width = 30,
    sidebar_header = {
      enabled = false,
      align = "center",
      rounded = false,
    },
    input = {
      prefix = " ",
      height = 8,
    },
    edit = {
      border = "none",
      start_insert = true,
    },
    ask = {
      floating = true,
      start_insert = true,
      border = "none",
      ---@type "ours" | "theirs"
      focus_on_apply = "ours",
    },
  },
  highlights = {
    diff = {
      current = "DiffText",
      incoming = "DiffAdd",
    },
  },
  diff = {
    autojump = true,
    ---@type string | fun(): any
    list_opener = "copen",
    override_timeoutlen = 1000,
  },
})
