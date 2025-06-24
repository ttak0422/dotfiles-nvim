-- vim.env.ANTHROPIC_API_KEY=...
pcall(dofile, vim.env.HOME .. "/.config/nvim/avante.lua")

local avante = require("avante")
require("avante_lib").load()
avante.setup({
  provider = "claude",
  auto_suggestions_provider = "claude",
  dual_boost = { enabled = false },
  hints = { enabled = true },
  behaviour = {
    auto_suggestion = false,
    auto_set_highlight_group = true,
    auto_set_keymaps = true,
    auto_apply_diff_after_generation = false,
    support_paste_from_clipboard = false,
    minimize_diff = true,
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
    ask = "<leader>aa",
    edit = "<leader>ae",
    refresh = "<leader>ar",
    focus = "<leader>af",
    toggle = {
      default = "<leader>at",
      debug = "<leader>ad",
      hint = "<leader>ah",
      suggestion = "<leader>as",
      repomap = "<leader>aR",
    },
    sidebar = {
      apply_all = "A",
      apply_cursor = "a",
      retry_user_request = "r",
      edit_user_request = "e",
      switch_windows = "<Tab>",
      reverse_switch_windows = "<S-Tab>",
      remove_file = "D",
      add_file = "@",
      close = { "<Esc>", "q" },
      close_from_input = { normal = "q" },
    },
  },
  windows = {
    ---@type "right" | "left" | "top" | "bottom"
    position = "right",
    wrap = true,
    width = 50,
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
      start_insert = false,
    },
    ask = {
      floating = false,
      start_insert = false,
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

local toggler = require("toggler")
toggler.register("avante", {
  open = function()
    avante.open_sidebar()
  end,
  close = function()
    avante.close_sidebar()
  end,
  is_open = function()
    return avante.is_sidebar_open()
  end,
})

vim.api.nvim_create_user_command("TAvanteToggle", function()
  toggler.toggle("avante")
end, {})
