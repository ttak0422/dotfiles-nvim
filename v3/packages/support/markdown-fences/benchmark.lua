local path, case = ...
-- Equal display geometry; wrap is disabled to isolate parser/highlighter work.
vim.o.wrap = false
vim.o.swapfile = false
vim.o.undofile = false
local LT = require("vim.treesitter.languagetree")
local original = LT._parse_regions
local stats = {}
-- Instrumentation only: _parse_regions returns the C parser's measured ns.
LT._parse_regions = function(self, ...)
	local changes, regions, ns = original(self, ...)
	stats[self:lang()] = (stats[self:lang()] or 0) + ns / 1e6
	return changes, regions, ns
end
local function timed(f)
	stats = {}
	local start = vim.uv.hrtime()
	f()
	vim.cmd.redraw()
	vim.wait(100) -- identical event-drain floor, included in wall time
	return { ms = (vim.uv.hrtime() - start) / 1e6, parse_ms = stats }
end
vim.cmd.edit(vim.fn.fnameescape(path))
vim.cmd("normal! " .. (case == "normal" and "492" or "500") .. "Gzz")
vim.cmd.redraw()
vim.wait(1000)
local result = { version = vim.version(), edits = {}, code_edits = {}, moves = {} }
for i = 1, 5 do
	result.edits[i] = timed(function()
		vim.cmd("normal! Ax")
		vim.api.nvim_exec_autocmds("TextChanged", { buffer = 0 })
		vim.api.nvim_exec_autocmds("CursorMoved", { buffer = 0 })
	end)
end
vim.cmd("normal! " .. (case == "normal" and "495" or "905") .. "Gzz")
for i = 1, 5 do
	result.code_edits[i] = timed(function()
		vim.cmd("normal! Ax")
		vim.api.nvim_exec_autocmds("TextChanged", { buffer = 0 })
		vim.api.nvim_exec_autocmds("CursorMoved", { buffer = 0 })
	end)
end
for i = 1, 5 do
	result.moves[i] = timed(function()
		vim.cmd("normal! 5j")
		vim.api.nvim_exec_autocmds("CursorMoved", { buffer = 0 })
	end)
end
result.indent = timed(function()
	vim.cmd("normal! ==")
end)
result.save = timed(function()
	vim.cmd("silent write")
end)
result.children = vim.tbl_keys(vim.treesitter.get_parser():children())
result.errors = vim.v.errmsg
result.messages = vim.api.nvim_exec2("messages", { output = true }).output
return result
