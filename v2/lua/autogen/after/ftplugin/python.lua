-- [nfnl] v2/fnl/after/ftplugin/python.fnl
if (vim.fn.expand("%:e") == "ipynb") then
  for mode, kvp in pairs({n = {["<LocalLeader>e"] = ":MoltenEvaluateOperator<CR>", ["<localleader>rr"] = ":MoltenReevaluateCell<CR>", ["<localleader>os"] = ":noautocmd MoltenEnterOutput<CR>", ["<localleader>oh"] = ":MoltenHideOutput<CR>", ["<localleader>mi"] = ":MoltenInit<CR>", ["<localleader>md"] = ":MoltenDelete<CR>"}, v = {["<localleader>r"] = ":<C-u>MoltenEvaluateVisual<CR>gv"}}) do
    for k, v in pairs(kvp) do
      vim.keymap.set(mode, k, v, {buffer = true, silent = true})
    end
  end
  return nil
else
  return nil
end
