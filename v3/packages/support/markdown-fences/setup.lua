-- Install before native ftplugins can create/cache a Markdown LanguageTree.
-- Keep the real block parser: it handles CommonMark fences inside lists/quotes.
local args = ...
vim.treesitter.query.add_predicate("v3-not-markdown-host?", function(match, _, source)
	if type(source) ~= "number" or vim.bo[source].filetype ~= "markdown" then
		return true
	end
	-- A Markdown document inside a fence is itself an injected language. Keep
	-- its normal highlights/injections, too. The host starts on the first row
	-- (possibly after a BOM); fenced content starts after its opener's row.
	for _, nodes in pairs(match) do
		local root = nodes[1]
		while root:parent() do
			root = root:parent()
		end
		local row = root:start()
		return row ~= 0
	end
	return false
end, { force = true })
vim.treesitter.query.set("markdown", "injections", args.injections)
vim.treesitter.query.set("markdown", "highlights", args.highlights)

local group = vim.api.nvim_create_augroup("v3_markdown_fences", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
	group = group,
	callback = function(ev)
		local previous = vim.b[ev.buf].v3_markdown_previous_filetype
		local current = vim.bo[ev.buf].filetype
		vim.b[ev.buf].v3_markdown_previous_filetype = current
		-- Filetype changes do not edit the buffer. Invalidate cached injections so
		-- Markdown <-> Vimwiki switches re-evaluate the buffer-local predicate.
		if previous ~= current and (previous == "markdown" or current == "markdown") then
			local parser = vim.treesitter.get_parser(ev.buf, "markdown", { error = false })
			if parser then
				parser:invalidate()
			end
		end
	end,
})
