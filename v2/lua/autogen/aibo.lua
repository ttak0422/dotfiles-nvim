-- [nfnl] v2/fnl/aibo.fnl
local aibo = require("aibo")
local prompt
local function _1_(bufnr, _info)
  for mode, maps in pairs({[{"n", "i"}] = {["<C-n>"] = "<Plug>(aibo-send)<C-n>", ["<C-p>"] = "<Plug>(aibo-send)<C-p>", ["<Down>"] = "<Plug>(aibo-send)<Down>", ["<Up>"] = "<Plug>(aibo-send)<Up>", ["<C-c>"] = "<Plug>(aibo-send)<Esc>"}, [{"n"}] = {["<CR>"] = "<Plug>(aibo-submit)"}, [{"i"}] = {["<C-s>"] = "<Plug>(aibo-submit)"}}) do
    for k, v in pairs(maps) do
      vim.keymap.set(mode, k, v, {buffer = bufnr, nowait = true, silent = true})
    end
  end
  return nil
end
prompt = {on_attach = _1_, no_default_mappings = false}
local console
local function _2_(_bufnr, _info)
end
console = {on_attach = _2_, no_default_mappings = false}
local tools
local function _3_(_bufnr, _info)
end
tools = {claude = {on_attach = _3_, no_default_mappings = false}, codex = {}}
return aibo.setup({prompt = prompt, console = console, tools = tools})
