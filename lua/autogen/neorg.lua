-- [nfnl] Compiled from fnl/neorg.fnl by https://github.com/Olical/nfnl, do not edit.
do
  local errorHl = vim.api.nvim_get_hl_by_name("@comment.error", true)
  local noteHl = vim.api.nvim_get_hl_by_name("@comment.note", true)
  for hl, spec in pairs({MarkAmbiguous = {fg = errorHl.background}, MarkHold = {fg = noteHl.background}}) do
    vim.api.nvim_set_hl(0, hl, spec)
  end
end
do
  local neorg = require("neorg")
  local defaults = {disable = {}}
  local dirman = {workspaces = {notes = "~/neorg", dotfiles = "~/ghq/github.com/ttak0422/Limbo/notes"}, default_workspace = "notes"}
  local highlights = {highlights = {todo_items = {on_hold = "+MarkHold", urgent = "+MarkAmbiguous"}}}
  local keybinds = {default_keybinds = false}
  local concealer = {icons = {code_block = {conceal = false}, heading = {icons = {"\243\176\188\143", "\243\176\142\168", "\243\176\188\145", "\243\176\142\178", "\243\176\188\147", "\243\176\142\180"}}, todo = {done = {icon = "\239\128\140"}, pending = {icon = "\239\132\144"}, undone = {icon = "\239\128\141"}, uncertain = {icon = "?"}, on_hold = {icon = "\239\137\150"}, cancelled = {icon = "\239\135\184"}, recurring = {icon = "\239\128\161"}, urgent = {icon = "\239\129\177"}}}}
  local journal = {journal_folder = "journal", strategy = "nested"}
  local metagen = {type = "auto"}
  local load = {["core.autocommands"] = {}, ["core.defaults"] = {config = defaults}, ["core.dirman"] = {config = dirman}, ["core.highlights"] = {config = highlights}, ["core.integrations.treesitter"] = {}, ["core.keybinds"] = {config = keybinds}, ["core.storage"] = {}, ["core.summary"] = {}, ["core.ui"] = {}, ["core.journal"] = {config = journal}, ["core.esupports.metagen"] = {config = metagen}, ["core.concealer"] = {config = concealer}, ["core.tempus"] = {}, ["core.ui.calendar"] = {}, ["core.integrations.telescope"] = {}, ["external.jupyter"] = {}}
  neorg.setup({load = load})
end
return vim.api.nvim_create_user_command("NeorgFuzzySearch", "Telescope neorg find_linkable", {})
