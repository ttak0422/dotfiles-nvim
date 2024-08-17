-- [nfnl] Compiled from fnl/after/norg.fnl by https://github.com/Olical/nfnl, do not edit.
for k, v in pairs({conceallevel = 3, swapfile = false, wrap = false}) do
  vim.opt_local[k] = v
end
local map = vim.keymap.set
local opts
local function _1_(d)
  return {noremap = true, silent = true, buffer = true, desc = d}
end
opts = _1_
local N = {{"<LocalLeader>nn", "<Plug>(neorg.dirman.new-note)", opts("\238\152\179 Create a new note")}, {"<LocalLeader>tu", "<Plug>(neorg.qol.todo-items.todo.task-undone)", opts("\238\152\179 Mark as undone")}, {"<LocalLeader>tp", "<Plug>(neorg.qol.todo-items.todo.task-pending)", opts("\238\152\179 Mark as pending")}, {"<LocalLeader>td", "<Plug>(neorg.qol.todo-items.todo.task-done)", opts("\238\152\179 Mark as done")}, {"<LocalLeader>th", "<Plug>(neorg.qol.todo-items.todo.task-on-hold)", opts("\238\152\179 Mark as on hold")}, {"<LocalLeader>tc", "<Plug>(neorg.qol.todo-items.todo.task-cancelled)", opts("\238\152\179 Mark as on cancelled")}, {"<LocalLeader>tr", "<Plug>(neorg.qol.todo-items.todo.task-recurring)", opts("\238\152\179 Mark as recurring")}, {"<LocalLeader>ti", "<Plug>(neorg.qol.todo-items.todo.task-important)", opts("\238\152\179 Mark as important")}, {"<LocalLeader>ta", "<Plug>(neorg.qol.todo-items.todo.task-ambiguous)", opts("\238\152\179 Mark as ambiguous")}, {"<C-Space>", "<Plug>(neorg.qol.todo-items.todo.task-cycle)", opts("\238\152\179 Cycle task")}, {"<CR>", "<Plug>(neorg.esupports.hop.hop-link)", opts("\238\152\179 Jump to link")}, {"<LocalLeader>lt", "<Plug>(neorg.pivot.list.toggle)", opts("\238\152\179 Toggle (un)ordered list")}, {"<LocalLeader>li", "<Plug>(neorg.pivot.list.invert)", opts("\238\152\179 Invert (un)ordered list")}, {"<LocalLeader>E", "<Plug>(neorg.looking-glass.magnify-code-block)", opts("\238\152\179 Edit code block")}, {"<LocalLeader>id", "<Plug>(neorg.tempus.insert-date)", opts("\238\152\179 Insert date")}}
local I = {{"<C-t>", "<Plug>(neorg.promo.promote)", opts("\238\152\179 Promote object")}, {"<C-d>", "<Plug>(neorg.promo.demote)", opts("\238\152\179 Demote object")}, {"<C-CR>", "<Plug>(neorg.itero.next-iteration)", opts("\238\152\179 Continue object")}}
local V = {{">", "<Plug>(neorg.promo.promote.range)", opts("\238\152\179 Promote range")}, {"<", "<Plug>(neorg.promo.demote.range)", opts("\238\152\179 Demote range")}}
for mode, ks in pairs({n = N, i = I, v = V}) do
  for _, k in ipairs(ks) do
    map(mode, k[1], k[2], k[3])
  end
end
return nil
