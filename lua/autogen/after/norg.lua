-- [nfnl] Compiled from fnl/after/norg.fnl by https://github.com/Olical/nfnl, do not edit.
for k, v in pairs({conceallevel = 3, concealcursor = "n", swapfile = false, wrap = false}) do
  vim.opt_local[k] = v
end
vim.opt_local.iskeyword:append({"$", "/"})
local map = vim.keymap.set
local opts
local function _1_(d)
  return {silent = true, buffer = true, desc = d, noremap = false}
end
opts = _1_
local N
local function _2_()
  require("neorg.core.modules").get_module("core.esupports.metagen").skip_next_update()
  return vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("u<c-o>", true, false, true), "n", false)
end
local function _3_()
  require("neorg.core.modules").get_module("core.esupports.metagen").skip_next_update()
  return vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<c-r><c-o>", true, false, true), "n", false)
end
N = {{"u", _2_, opts("\238\152\179 undo")}, {"<C-r>", _3_, opts("\238\152\179 redo")}, {"<LocalLeader>nn", "<Plug>(neorg.dirman.new-note)", opts("\238\152\179 Create a new note")}, {"<LocalLeader>tu", "<Plug>(neorg.qol.todo-items.todo.task-undone)", opts("\238\152\179 Mark as undone")}, {"<LocalLeader>tp", "<Plug>(neorg.qol.todo-items.todo.task-pending)", opts("\238\152\179 Mark as pending")}, {"<LocalLeader>td", "<Plug>(neorg.qol.todo-items.todo.task-done)", opts("\238\152\179 Mark as done")}, {"<LocalLeader>th", "<Plug>(neorg.qol.todo-items.todo.task-on-hold)", opts("\238\152\179 Mark as on hold")}, {"<LocalLeader>tc", "<Plug>(neorg.qol.todo-items.todo.task-cancelled)", opts("\238\152\179 Mark as on cancelled")}, {"<LocalLeader>tr", "<Plug>(neorg.qol.todo-items.todo.task-recurring)", opts("\238\152\179 Mark as recurring")}, {"<LocalLeader>ti", "<Plug>(neorg.qol.todo-items.todo.task-important)", opts("\238\152\179 Mark as important")}, {"<LocalLeader>ta", "<Plug>(neorg.qol.todo-items.todo.task-ambiguous)", opts("\238\152\179 Mark as ambiguous")}, {"<C-Space>", "<Plug>(neorg.qol.todo-items.todo.task-cycle)", opts("\238\152\179 Cycle task")}, {"<CR>", "<Plug>(neorg.esupports.hop.hop-link)", opts("\238\152\179 Jump to link")}, {"<LocalLeader>lt", "<Plug>(neorg.pivot.list.toggle)", opts("\238\152\179 Toggle (un)ordered list")}, {"<LocalLeader>li", "<Plug>(neorg.pivot.list.invert)", opts("\238\152\179 Invert (un)ordered list")}, {"<LocalLeader>E", "<Plug>(neorg.looking-glass.magnify-code-block)", opts("\238\152\179 Edit code block")}, {"<LocalLeader>id", "<Plug>(neorg.tempus.insert-date)", opts("\238\152\179 Insert date")}}
local I = {{"<C-l>", "<C-o><Plug>(neorg.telescope.insert_link)", opts("\238\152\179 Insert link")}, {"<C-t>", "<C-o><Plug>(neorg.promo.promote)", opts("\238\152\179 Promote object")}, {"<C-d>", "<C-o><Plug>(neorg.promo.demote)", opts("\238\152\179 Demote object")}}
local V = {{">", "<Plug>(neorg.promo.promote.range)", opts("\238\152\179 Promote range")}, {"<", "<Plug>(neorg.promo.demote.range)", opts("\238\152\179 Demote range")}}
for mode, ks in pairs({n = N, i = I, v = V}) do
  for _, k in ipairs(ks) do
    map(mode, k[1], k[2], k[3])
  end
end
return nil
