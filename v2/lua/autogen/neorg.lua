-- [nfnl] v2/fnl/neorg.fnl
local neorg = require("neorg")
local telescope_builtin = require("telescope.builtin")
local vault_path = "~/neorg"
do
  local metagen = {type = "auto", undojoin_updates = true}
  local journal = {journal_folder = "journal", strategy = "flat"}
  local keybinds = {default_keybinds = false}
  local completion = {engine = {module_name = "external.lsp-completion"}}
  local interim_ls = {completion_provider = {enable = true, documentation = true, categories = false}}
  local concealer = {icons = {code_block = {conceal = false}, heading = {icons = {"\243\176\188\143", "\243\176\142\168", "\243\176\188\145", "\243\176\142\178", "\243\176\188\147", "\243\176\142\180"}}, todo = {done = {icon = "\239\128\140"}, pending = {icon = "\243\176\158\140"}, undone = {icon = "\239\128\141"}, uncertain = {icon = "?"}, on_hold = {icon = "\239\128\163"}, cancelled = {icon = "\239\135\184"}, recurring = {icon = "\239\128\161"}, urgent = {icon = "\239\148\155"}}}}
  local dirman = {workspaces = {default = vault_path}, default_workspace = "default"}
  local markdown = {extensions = "all"}
  local load = {["core.defaults"] = {config = {disable = {}}}, ["core.esupports.metagen"] = {config = metagen}, ["core.journal"] = {config = journal}, ["core.keybinds"] = {config = keybinds}, ["core.completion"] = {config = completion}, ["core.concealer"] = {config = concealer}, ["core.dirman"] = {config = dirman}, ["core.export.markdown"] = {config = markdown}, ["core.integrations.telescope"] = {}, ["external.interim-ls"] = {config = interim_ls}, ["external.conceal-wrap"] = {}}
  neorg.setup({load = load})
end
local dirman = neorg.modules.get_module("core.dirman")
local path = require("plenary.path")
local git_dir_3f
local function _1_()
  return path:new((vim.fn.getcwd() .. "/.git")):exists()
end
git_dir_3f = _1_
local get_dir
local function _2_()
  return vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
end
get_dir = _2_
local get_branch
local function _3_()
  local out = vim.fn.system("git rev-parse --abbrev-ref HEAD")
  if (vim.v.shell_error == 0) then
    return out:gsub("%s+", "")
  else
    return error("branch not found")
  end
end
get_branch = _3_
local create_file
local function _5_(path0)
  return dirman.create_file(path0, nil, {})
end
create_file = _5_
local dated_title
local function _6_(title)
  local function _7_(t)
    return (os.date("%Y%m%d%H%M%S") .. "_" .. t)
  end
  return _7_(string.gsub(title, " ", "_"))
end
dated_title = _6_
local scratch_path
local function _8_(path0)
  return ("scratch/" .. path0)
end
scratch_path = _8_
local commands
local function _9_()
  return telescope_builtin.live_grep({cwd = vault_path})
end
local function _10_()
  local case_11_ = vim.fn.input("\238\152\179 Title: ")
  local and_12_ = (nil ~= case_11_)
  if and_12_ then
    local title = case_11_
    and_12_ = (title ~= "")
  end
  if and_12_ then
    local title = case_11_
    return create_file(scratch_path(dated_title(title)))
  else
    return nil
  end
end
local function _15_()
  if git_dir_3f() then
    return create_file(("project/" .. get_dir() .. "/main"))
  else
    return vim.notify("Not a git repository", "warn")
  end
end
local function _17_()
  if git_dir_3f() then
    return create_file(("project/" .. get_dir() .. "/" .. get_branch()))
  else
    return vim.notify("Not a git repository", "warn")
  end
end
commands = {NeorgFindFile = "Telescope neorg find_norg_files", NeorgFuzzySearch = _9_, NeorgScratch = _10_, NeorgGit = _15_, NeorgGitBranch = _17_}
for name, fun in pairs(commands) do
  vim.api.nvim_create_user_command(name, fun, {})
end
return nil
