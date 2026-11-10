local ts = vim.treesitter
local function buffer(ft, lines)
	local b = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_set_current_buf(b)
	vim.api.nvim_buf_set_lines(b, 0, -1, false, lines)
	vim.bo[b].filetype = ft
	return b
end
local function parse(b)
	local p = ts.get_parser(b, "markdown")
	p:parse(true)
	return p
end
local function captures(p, source, lang)
	local count = 0
	p:for_each_tree(function(tree, lt)
		if lt:lang() == lang then
			local q = ts.query.get(lang, "highlights")
			if q then
				for _ in q:iter_captures(tree:root(), source, 0, -1) do
					count = count + 1
				end
			end
		end
	end)
	return count
end
local text = {
	"---",
	"title: test",
	"---",
	"# Heading",
	"",
	"Prose **bold** `inline_code` ![alt](image.png)",
	"",
	"<div>HTML</div>",
	"",
	"```lua",
	"local answer = 42",
	"```",
	"",
	"~~~vim",
	"let g:answer = 42",
	"~~~",
	"",
	"```bash",
	'echo "$HOME"',
	"```",
	"",
	"```python",
	"answer = 42",
	"```",
	"",
	"```sh",
	"echo alias",
	"```",
	"",
	"```unknown_language_v3",
	"not highlighted",
	"```",
	"",
	"```",
	"no language",
	"```",
	"",
	"## Next heading",
}
-- Open Vimwiki first, then Markdown; cached queries must not bind to first FT.
local wiki = buffer("vimwiki", text)
local wp = parse(wiki)
assert(wp:children().markdown_inline, "Vimwiki lost inline parser")
local images = ts.query.parse("markdown_inline", "(image) @image")
local image_count = 0
wp:children().markdown_inline:for_each_tree(function(tree)
	for _ in images:iter_captures(tree:root(), wiki, 0, -1) do
		image_count = image_count + 1
	end
end)
assert(image_count == 1, "Vimwiki image discovery query changed")
assert(wp:children().html and wp:children().yaml, "Vimwiki lost stock injections")
assert(captures(wp, wiki, "markdown") > 0, "Vimwiki lost block highlights")
local md = buffer("markdown", text)
local p = parse(md)
assert(p:lang() == "markdown", "block-parser language identity changed")
assert(not p:children().markdown_inline, "Markdown still parses inline content")
assert(not p:children().html and not p:children().yaml, "host-only injections remain")
for _, lang in ipairs({ "lua", "vim", "bash", "python" }) do
	assert(p:children()[lang], "missing fenced " .. lang)
	assert(captures(p, md, lang) > 0, "missing real fenced captures: " .. lang)
end
assert(captures(p, md, "markdown") == 0, "host Markdown still highlighted")
assert(vim.bo[md].syntax == "", "regex syntax unexpectedly enabled")
assert(not vim.bo[md].indentexpr:find("treesitter", 1, true), "TS indent still enabled")
assert(vim.api.nvim_eval(vim.wo.foldexpr) == 0, "TS foldexpr still enabled")
local ufo = require("ufo.config")
assert(ufo.provider_selector(md, "markdown", "") == "indent", "Markdown UFO provider")
assert(vim.deep_equal(ufo.provider_selector(md, "lua", ""), { "treesitter", "indent" }))
for _ = 1, 4 do
	vim.api.nvim_exec_autocmds("FileType", { buffer = md })
end
assert(ts.highlighter.active[md], "repeated FileType lost highlighter")
assert(parse(md) == p and not p:children().markdown_inline, "repeated FileType changed policy")
vim.api.nvim_win_set_cursor(0, { 4, 0 })
require("vim.treesitter._headings").jump({ count = 1 })
assert(vim.api.nvim_win_get_cursor(0)[1] == #text, "native heading navigation broke")
-- FT changes without edits must invalidate cached injection ranges both ways.
vim.bo[md].filetype = "vimwiki"
assert(parse(md):children().markdown_inline, "Markdown -> Vimwiki cache stale")
assert(captures(parse(md), md, "markdown") > 0)
vim.bo[md].filetype = "markdown"
assert(not parse(md):children().markdown_inline, "Vimwiki -> Markdown cache stale")
assert(captures(parse(md), md, "markdown") == 0)
-- Opposite opening order and simultaneous buffers.
local wiki2 = buffer("vimwiki", text)
assert(parse(wiki2):children().markdown_inline)
assert(not parse(md):children().markdown_inline)
local sp = ts.get_string_parser(table.concat(text, "\n"), "markdown")
sp:parse(true)
assert(sp:children().markdown_inline and sp:children().html and sp:children().yaml)
assert(captures(sp, table.concat(text, "\n"), "markdown") > 0)

local cases = {
	{ "tilde", { "~~~~lua", "local x = 1", "~~~~~", "outside" }, { { 1, 0, 2, 0 } } },
	{ "short closer", { "````lua", "local x = 1", "```", "local y = 2", "````" }, { { 1, 0, 4, 0 } } },
	{ "indented", { "  ```lua", "  local x = 1", "  ```" }, { { 1, 2, 2, 0 } } },
	{ "list", { "- item", "", "  ```lua", "  local x = 1", "  ```" }, { { 3, 2, 4, 0 } } },
	{ "quote", { "> ```lua", "> local x = 1", "> ```" }, { { 1, 2, 2, 0 } } },
	{ "unclosed", { "```lua", "local x = 1" }, { { 1, 0, 2, 0 } } },
	{
		"repeated",
		{ "```lua", "local x = 1", "```", "", "```lua", "local y = 2", "```" },
		{ { 1, 0, 2, 0 }, { 5, 0, 6, 0 } },
	},
}
for _, case in ipairs(cases) do
	local b = buffer("markdown", case[2])
	local cp = parse(b)
	assert(cp:children().lua, case[1] .. ": missing Lua child")
	local ranges = {}
	for _, tree in pairs(cp:children().lua:trees()) do
		table.insert(ranges, { tree:root():range() })
	end
	table.sort(ranges, function(a, b)
		return a[1] < b[1]
	end)
	assert(vim.deep_equal(ranges, case[3]), case[1] .. ": wrong code boundary " .. vim.inspect(ranges))
	assert(captures(cp, b, "lua") > 0, case[1] .. ": missing Lua captures")
	assert(captures(cp, b, "markdown") == 0, case[1] .. ": host capture")
	vim.api.nvim_buf_delete(b, { force = true })
end
local bom = buffer("markdown", { "\239\187\191**bold** `inline_code`", "", "```lua", "local x = 1", "```" })
assert(not parse(bom):children().markdown_inline, "literal BOM bypassed the host policy")
assert(captures(parse(bom), bom, "markdown") == 0, "literal BOM restored host highlights")
assert(captures(parse(bom), bom, "lua") > 0, "literal BOM lost fenced code")
local nested = buffer(
	"markdown",
	{ "````markdown", "# Nested heading", "", "**bold** `code`", "", "```lua", "local x = 1", "```", "````" }
)
local np = parse(nested)
assert(np:children().markdown, "nested Markdown language missing")
assert(np:children().markdown:children().markdown_inline, "nested Markdown lost inline highlighting")
assert(captures(np:children().markdown, nested, "markdown") > 0, "nested Markdown host highlights missing")
assert(captures(np, nested, "lua") > 0, "nested Lua captures missing")
local b = buffer("markdown", { "```lua", "local x = 1", "```" })
local bp = parse(b)
vim.api.nvim_buf_set_lines(b, 0, 1, false, { "```python" })
assert(parse(b):children().python and not bp:children().lua, "fence language edit stale")
vim.api.nvim_buf_set_lines(b, 0, 1, false, { "plain prose" })
assert(not parse(b):children().python, "removed fence left highlights")
vim.api.nvim_buf_set_lines(b, 0, -1, false, { "```lua", "local x = 1", "```" })
assert(parse(b):children().lua, "re-added fence not highlighted")
vim.bo[b].filetype = "lua"
assert(ts.get_parser(b):lang() == "lua", "Markdown -> Lua parser stale")
assert(ts.highlighter.active[b].tree:lang() == "lua", "Markdown -> Lua highlighter stale")
vim.bo[b].filetype = "markdown"
assert(ts.get_parser(b):lang() == "markdown" and not parse(b):children().markdown_inline)
local lua = buffer("lua", { "local answer = 42" })
local lp = ts.get_parser(lua, "lua")
lp:parse(true)
assert(captures(lp, lua, "lua") > 0, "ordinary Lua highlighting changed")
assert(ts.highlighter.active[lua].tree == lp, "ordinary Lua highlighter not attached")
-- Query behavior changes only Markdown buffers, not parser availability.
assert(ts.language.add("markdown_inline"))
print("Markdown fenced highlights: captures, boundaries, lifecycle and unaffected sources passed")
