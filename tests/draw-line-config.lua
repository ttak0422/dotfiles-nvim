-- DRAW_LINE_PLUGIN_DIR=<pinned draw-line> HYDRA_PLUGIN_DIR=<pinned hydra>
-- NFNL_PLUGIN_DIR=<pinned nfnl> nvim --headless -u NONE -i NONE -l tests/draw-line-config.lua
for _, name in ipairs({ "DRAW_LINE_PLUGIN_DIR", "HYDRA_PLUGIN_DIR", "NFNL_PLUGIN_DIR" }) do
  vim.opt.rtp:append(assert(vim.env[name], name))
end
local path = "v2/fnl/draw-line.fnl"
local compiled = "-- [nfnl] "
  .. path
  .. "\n"
  .. require("nfnl.fennel")["compile-string"](table.concat(vim.fn.readfile(path), "\n"), { filename = path })
assert(compiled == table.concat(vim.fn.readfile("v2/lua/autogen/draw-line.lua"), "\n"))
vim.g.mapleader = " "
dofile("v2/lua/autogen/draw-line.lua")
local function keys(s)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(s, true, false, true), "xt", false)
end
local function reset()
  vim.cmd.enew({ bang = true })
  vim.wo.virtualedit = "block"
  vim.o.selection = "exclusive"
end
local function eq(a, b)
  assert(vim.deep_equal(a, b), vim.inspect(a) .. " ~= " .. vim.inspect(b))
end
reset()
keys(" VLLJ<Esc>")
eq(vim.api.nvim_buf_get_lines(0, 0, -1, false), { "──┐", "  ▼" })
eq(vim.wo.virtualedit, "block")
eq(vim.o.selection, "exclusive")
for key, expected in pairs({
  f = { "┌──┐", "│  │", "└──┘" },
  r = { "╔══╗", "║  ║", "╚══╝" },
  v = { "┏━━┓", "┃  ┃", "┗━━┛" },
}) do
  reset()
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { "", "", "" })
  keys(" V<C-v>3l2j" .. key .. "<Esc>")
  eq(vim.api.nvim_buf_get_lines(0, 0, -1, false), expected)
  eq(vim.wo.virtualedit, "block")
  eq(vim.o.selection, "exclusive")
end
reset()
keys(" VJJLLHHKK<Esc>")
eq(vim.api.nvim_win_get_cursor(0), { 1, 0 })
eq(vim.wo.virtualedit, "block")
eq(vim.o.selection, "exclusive")
print("PASS Hydra entry, direction keys, single/double/heavy Visual Block boxes, exit option restoration")

reset()
local draw = require("draw-line")
assert(draw.draw("l", "dashed3"))
assert(draw.draw("l", "dashed3"))
eq(vim.api.nvim_get_current_line(), "┄┄▶")
assert(not package.loaded.venn)
print("PASS generated Lua parity, dashed drawing, and no venn module loaded")
