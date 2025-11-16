-- [nfnl] v2/fnl/buffer-plugins.fnl
local cachedir = vim.fn.stdpath("cache")
for k, v in pairs({updatetime = 100, hidden = true, autoread = true, undofile = true, undodir = (cachedir .. "/undo"), swapfile = true, directory = (cachedir .. "/swap"), backup = true, backupcopy = "yes", backupdir = (cachedir .. "/backup"), listchars = "tab:> ,trail:-", list = true, equalalways = false, startofline = false}) do
  vim.opt[k] = v
end
do
  local opts = {noremap = true, silent = true}
  local desc
  local function _1_(d)
    return {noremap = true, silent = true, desc = d}
  end
  desc = _1_
  local toggle
  local function _2_(id)
    local function _3_()
      return require("toggler").toggle(id)
    end
    return _3_
  end
  toggle = _2_
  local function _4_()
    return require("open").open_cword()
  end
  local function _5_()
    return require("dap").toggle_breakpoint()
  end
  local function _6_()
    return require("dap").repl.toggle()
  end
  local function _7_()
    return require("dap").run_last()
  end
  for _, k in ipairs({{"<Leader>tz", "<Cmd>NeoZoomToggle<CR>", desc("\239\136\132 zoom")}, {"<Leader>tm", "<Cmd>lua require('codewindow').toggle_minimap()<CR>", desc("\239\136\132 minimap")}, {"<Leader>to", toggle("aerial"), desc("\239\136\132 outline")}, {"<Leader>U", "<Cmd>Atone<CR>", desc("\239\136\132 undotree")}, {"gx", _4_, desc("open")}, {"<Leader>gb", "<Cmd>BlameToggle<CR>", desc("\239\135\147 blame")}, {"<LocalLeader>db", _5_, desc("\238\171\152 breakpoint")}, {"<LocalLeader>dr", _6_, desc("\238\171\152 repl")}, {"<LocalLeader>dl", _7_, desc("\238\171\152 run last")}, {"<LocalLeader>dd", toggle("dapui"), desc("\238\171\152 run last")}}) do
    vim.keymap.set("n", k[1], k[2], (k[3] or opts))
  end
end
local function _8_()
  local buf = vim.api.nvim_get_current_buf()
  local name = vim.api.nvim_buf_get_name(buf)
  local root = vim.fs.root(buf, {".git", "gradlew", "package.json"})
  local name0
  if root then
    name0 = vim.fn.fnamemodify(name, (":." .. root))
  else
    name0 = name
  end
  local base = vim.fn.fnamemodify(name0, ":t")
  local dir = vim.fn.fnamemodify(name0, ":h")
  local prefix
  local _10_
  if vim.bo.modified then
    _10_ = "\239\145\132 "
  else
    _10_ = "  "
  end
  prefix = ("%#Normal#%*" .. _10_)
  local _12_
  if (name0 == "") then
    _12_ = "[No Name]"
  else
    if (dir == ".") then
      _12_ = base
    else
      _12_ = (base .. " - " .. dir)
    end
  end
  return (prefix .. _12_)
end
_G._winbar = _8_
vim.o.winbar = "%r%{%v:lua._winbar()%}"
return nil
