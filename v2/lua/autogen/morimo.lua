-- [nfnl] v2/fnl/morimo.fnl
for _, p in ipairs({"nvim-notify", "treesitter", "gitsigns", "lir", "dap", "git-conflict", "lir"}) do
  require("morimo").load(p)
end
return nil
