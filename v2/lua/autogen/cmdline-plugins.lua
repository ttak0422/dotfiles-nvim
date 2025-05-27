-- [nfnl] v2/fnl/cmdline-plugins.fnl
for k, v in pairs({ignorecase = true, smartcase = true, hlsearch = true, incsearch = true}) do
  vim.opt[k] = v
end
local opts = {noremap = true, silent = true}
local desc
local function _1_(d)
  return {noremap = true, silent = true, desc = d}
end
desc = _1_
local function _2_()
  return vim.cmd("vimgrep //gj %")
end
local function _3_()
  return vim.cmd("vimgrepadd //gj %")
end
for _, k in ipairs({{"<Leader>/", _2_, desc("register search results to qf")}, {"<Leader>?", _3_, desc("add search results to qf")}}) do
  vim.keymap.set("n", k[1], k[2], (k[3] or opts))
end
return nil
