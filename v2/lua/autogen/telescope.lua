-- [nfnl] v2/fnl/telescope.fnl
local telescope = require("telescope")
local builtin = require("telescope.builtin")
local themes = require("telescope.themes")
local actions = require("telescope.actions")
local lga_actions = require("telescope-live-grep-args.actions")
local defaults
local function _1_(self, _, _0)
  local winid = self.original_win_id
  local win_width = vim.api.nvim_win_get_width(winid)
  local cursor = vim.api.nvim_win_get_cursor(winid)
  local col = cursor[2]
  return math.max(80, (win_width - col - 2))
end
local function _2_(self, _, _0)
  local winid = self.original_win_id
  local win_height = vim.api.nvim_win_get_height(winid)
  local cursor = vim.api.nvim_win_get_cursor(winid)
  local row = cursor[1]
  return math.max(10, (win_height - row - 2))
end
defaults = themes.get_cursor({path_display = {"truncate"}, prompt_prefix = "\239\128\130 ", selection_caret = "\239\129\161 ", layout_config = {width = _1_, height = _2_}, mappings = {i = {["<C-j>"] = {"<Plug>(skkeleton-enable)", type = "command"}, ["<Down>"] = actions.cycle_history_next, ["<Up>"] = actions.cycle_history_prev}, n = {["<Down>"] = actions.cycle_history_next, ["<Up>"] = actions.cycle_history_prev}}, preview = false})
local extensions
local function _3_()
  return {"--hidden", "--glob", "!.git/**"}
end
extensions = {live_grep_args = {auto_quoting = true, mappings = {i = {["<C-t>"] = lga_actions.quote_prompt({postfix = " -t "}), ["<C-i>"] = lga_actions.quote_prompt({postfix = " --iglob "})}}, additional_args = _3_}}
telescope.setup({defaults = defaults, extensions = extensions})
telescope.load_extension("live_grep_args")
telescope.load_extension("sonictemplate")
telescope.load_extension("projects")
telescope.load_extension("mr")
telescope.load_extension("ghq")
local function _4_()
  return builtin.live_grep({grep_open_files = true})
end
vim.api.nvim_create_user_command("TelescopeBuffer", _4_, {})
local function _5_()
  return builtin.buffers({sort_mru = true, ignore_current_buffer = false})
end
return vim.api.nvim_create_user_command("TelescopeBufferName", _5_, {})
