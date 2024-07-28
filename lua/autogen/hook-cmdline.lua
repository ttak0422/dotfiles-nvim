-- [nfnl] Compiled from fnl/hook-cmdline.fnl by https://github.com/Olical/nfnl, do not edit.
local cabbrev_path = args.cabbrev_path
do
  local cmd = vim.api.nvim_create_user_command
  local function _1_(opts)
    local command
    if opts.bang then
      command = "vimgrepadd"
    else
      command = "vimgrep"
    end
    local pattern = "//gj %"
    return vim.cmd((command .. " " .. pattern))
  end
  cmd("SearchToQf", _1_, {bang = true})
end
do
  local opts = {ignorecase = true, smartcase = true, hlsearch = true, incsearch = true}
  for k, v in pairs(opts) do
    vim.o[k] = v
  end
end
do
  local opts = {noremap = true, silent = true}
  local desc
  local function _3_(d)
    return {noremap = true, silent = true, desc = d}
  end
  desc = _3_
  local cmd
  local function _4_(c)
    return ("<cmd>" .. c .. "<cr>")
  end
  cmd = _4_
  local N = {{"<leader>/", cmd("SearchToQf"), desc("register search results to quickfix")}, {"<leader>?", cmd("SearchToQf!", desc("add search results to quickfix"))}}
  for _, k in ipairs(N) do
    vim.keymap.set("n", k[1], k[2], (k[3] or opts))
  end
end
return vim.cmd(("source " .. cabbrev_path))
