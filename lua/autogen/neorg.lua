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
  local metagen = {type = "auto", undojoin_updates = true}
  local load = {["core.autocommands"] = {}, ["core.defaults"] = {config = defaults}, ["core.dirman"] = {config = dirman}, ["core.highlights"] = {config = highlights}, ["core.integrations.treesitter"] = {}, ["core.keybinds"] = {config = keybinds}, ["core.storage"] = {}, ["core.summary"] = {}, ["core.ui"] = {}, ["core.journal"] = {config = journal}, ["core.esupports.metagen"] = {config = metagen}, ["core.concealer"] = {config = concealer}, ["core.tempus"] = {}, ["core.ui.calendar"] = {}, ["core.integrations.telescope"] = {}, ["external.jupyter"] = {}}
  neorg.setup({load = load})
end
local neorg = require("neorg")
local path = require("plenary.path")
local dirman = neorg.modules.get_module("core.dirman")
local create_command = vim.api.nvim_create_user_command
local confirm
local function _1_(prompt)
  local answer = vim.fn.input((prompt .. " (y/N): "))
  return (answer:lower() == "y")
end
confirm = _1_
local check_git_dir
local function _2_()
  local git_dir = path:new((vim.fn.getcwd() .. "/.git"))
  return git_dir:exists()
end
check_git_dir = _2_
local get_dir
local function _3_()
  return vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
end
get_dir = _3_
local get_branch
local function _4_()
  local out = vim.fn.system("git rev-parse --abbrev-ref HEAD")
  if (vim.v.shell_error == 0) then
    return out:gsub("%s+", "")
  else
    return error("branch not found")
  end
end
get_branch = _4_
create_command("NeorgFuzzySearch", "Telescope neorg find_linkable", {})
local function _6_()
  if confirm("Create Note?") then
    local uid = os.date("%Y%m%d%H%M%S")
    return dirman.create_file(("uid/" .. uid), nil, {title = uid})
  else
    return nil
  end
end
create_command("NeorgUID", _6_, {})
local function _8_()
  if check_git_dir() then
    return dirman.create_file(("project/" .. get_dir() .. "/main"), nil, {title = ("Project " .. get_dir())})
  else
    return vim.notify("Not a git repository", "warn")
  end
end
create_command("NeorgGit", _8_, {})
local function _10_()
  if check_git_dir() then
    return dirman.create_file(("project/" .. get_dir() .. "/" .. get_branch()), nil, {title = ("Project " .. get_dir() .. "/" .. get_branch())})
  else
    return vim.notify("Not a git repository", "warn")
  end
end
return create_command("NeorgGitBranch", _10_, {})
