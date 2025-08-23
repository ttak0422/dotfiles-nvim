-- [nfnl] v2/fnl/telescope.fnl
local telescope = require("telescope")
local builtin = require("telescope.builtin")
local themes = require("telescope.themes")
local actions = require("telescope.actions")
local lga_actions = require("telescope-live-grep-args.actions")
local defaults = themes.get_ivy({path_display = {"truncate"}, prompt_prefix = "\239\128\130 ", selection_caret = "\239\129\161 ", mappings = {i = {["<C-j>"] = {"<Plug>(skkeleton-enable)", type = "command"}, ["<Down>"] = actions.cycle_history_next, ["<Up>"] = actions.cycle_history_prev}, n = {["<Down>"] = actions.cycle_history_next, ["<Up>"] = actions.cycle_history_prev}}})
local extensions = {live_grep_args = {auto_quoting = true, mappings = {i = {["<C-t>"] = lga_actions.quote_prompt({postfix = " -t "}), ["<C-i>"] = lga_actions.quote_prompt({postfix = " --iglob "})}}}}
telescope.setup({defaults = defaults, extensions = extensions})
telescope.load_extension("live_grep_args")
telescope.load_extension("sonictemplate")
telescope.load_extension("projects")
telescope.load_extension("mr")
local function _1_()
  return builtin.buffers({sort_mru = true, ignore_current_buffer = true})
end
return vim.api.nvim_create_user_command("TelescopeBuffer", _1_, {})
