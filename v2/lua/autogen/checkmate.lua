-- [nfnl] v2/fnl/checkmate.fnl
local checkmate = require("checkmate")
local files = {"todo", "TODO", "todo.md", "TODO.md", "*.todo", "*.todo.md", "scratch.md"}
local keys = {["<LocalLeader>tt"] = {rhs = "<cmd>Checkmate toggle<CR>", desc = "Toggle todo item", modes = {"n", "v"}}, ["<LocalLeader>td"] = {rhs = "<cmd>Checkmate check<CR>", desc = "Set todo item as checked (done)", modes = {"n", "v"}}, ["<LocalLeader>tu"] = {rhs = "<cmd>Checkmate uncheck<CR>", desc = "Set todo item as unchecked (not done)", modes = {"n", "v"}}, ["<LocalLeader>tn"] = {rhs = "<cmd>Checkmate create<CR>", desc = "Create todo item", modes = {"n", "v"}}, ["<LocalLeader>ta"] = {rhs = "<cmd>Checkmate archive<CR>", desc = "Archive checked/completed todo items (move to bottom section)", modes = {"n"}}}
local todo_states = {unchecked = {marker = "\226\150\161"}, checked = {marker = "\226\156\148"}, in_progress = {marker = "\226\151\144", markdown = ".", type = "incomplete", order = 50}, cancelled = {marker = "\239\135\184", markdown = "c", type = "complete", order = 2}, on_hold = {marker = "\226\143\184", markdown = "/", type = "inactive", order = 100}}
local todo_count_formatter
local function _1_(completed, total)
  if (total > 4) then
    local percent = ((completed / total) * 100)
    local bar_length = 10
    local filled = math.floor(((bar_length * percent) / 100)())
    local bar = (string.rep("\226\151\188\239\184\142", filled) .. string.rep("\226\151\187\239\184\142", (bar_length - filled)))
    string.format("%s", bar)
    return string.format("[%d/%d]", completed, total)
  else
    return nil
  end
end
todo_count_formatter = _1_
return checkmate.setup({files = files, keys = keys, todo_states = todo_states, todo_count_formatter = todo_count_formatter})
