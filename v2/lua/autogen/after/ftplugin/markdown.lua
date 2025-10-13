-- [nfnl] v2/fnl/after/ftplugin/markdown.fnl
for key, value in pairs({signcolumn = "no", foldcolumn = "0", listchars = "tab:> ", virtualedit = "all", number = false}) do
  vim.opt_local[key] = value
end
if (vim.fn.expand("%:e") == "ipynb") then
  require("quarto").activate()
  require("otter").activate()
  local runner = require("quarto.runner")
  for mode, kvp in pairs({n = {["<LocalLeader>e"] = ":MoltenEvaluateOperator<CR>", ["<localleader>rr"] = runner.run_cell, ["<localleader>ra"] = runner.run_above, ["<localleader>rA"] = runner.run_all, ["<localleader>rl"] = runner.run_line, ["<localleader>mi"] = ":MoltenInit<CR>", ["<localleader>md"] = ":MoltenDelete<CR>"}, v = {["<localleader>r"] = runner.run_range}}) do
    for k, v in pairs(kvp) do
      vim.keymap.set(mode, k, v, {buffer = true, silent = true})
    end
  end
  return nil
else
  return nil
end
