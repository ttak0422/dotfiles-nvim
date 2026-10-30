-- [nfnl] v2/fnl/after/ftplugin/markdown.fnl
for _, key in ipairs({"gO", "]]", "[["}) do
  local _2_
  do
    local t_1_ = vim.fn.maparg(key, "n", false, true)
    if (nil ~= t_1_) then
      t_1_ = t_1_.buffer
    else
    end
    _2_ = t_1_
  end
  if (_2_ == 1) then
    vim.keymap.del("n", key, {buffer = true})
  else
  end
end
for key, value in pairs({foldcolumn = "0", listchars = "tab:> ", virtualedit = "all", number = false}) do
  vim.opt_local[key] = value
end
vim.keymap.set({"n", "i"}, "<D-v>", "<Plug>(mdpaste)", {buffer = true})
if (vim.fn.expand("%:e") == "ipynb") then
  require("quarto").activate()
  require("otter").activate()
  local runner = require("quarto.runner")
  for mode, kvp in pairs({n = {["<LocalLeader>e"] = ":MoltenEvaluateOperator<CR>", ["<localleader>rr"] = runner.run_cell, ["<localleader>ra"] = runner.run_above, ["<localleader>rA"] = runner.run_all, ["<localleader>rl"] = runner.run_line, ["<localleader>mi"] = ":MoltenInit<CR>", ["<localleader>md"] = ":MoltenDelete<CR>"}, v = {["<localleader>r"] = runner.run_range}}) do
    for k, v in pairs(kvp) do
      vim.keymap.set(mode, k, v, {buf = 0, silent = true})
    end
  end
  return nil
else
  return nil
end
