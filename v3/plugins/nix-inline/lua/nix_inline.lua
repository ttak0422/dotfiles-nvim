local M = {}

---Enable injections in the first Nix buffer as well as subsequent ones.
---@param bufnr integer
function M.attach(bufnr)
	if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].filetype ~= "nix" then
		return
	end
	local parser = vim.treesitter.get_parser(bufnr, "nix", { error = false })
	if not parser then
		return
	end
	-- Re-evaluate injection language aliases even if another FileType hook
	-- already parsed this buffer before the lazy loader ran.
	parser:invalidate(true)
	vim.treesitter.start(bufnr, "nix")
end

---Install the FileType hook once and handle the event that loaded this plugin.
function M.setup()
	vim.treesitter.language.register("vim", "vimscript")
	vim.treesitter.language.register("bash", "sh")
	local group = vim.api.nvim_create_augroup("NixInline", { clear = true })
	vim.api.nvim_create_autocmd("FileType", {
		group = group,
		pattern = "nix",
		callback = function(event)
			M.attach(event.buf)
		end,
	})
	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(bufnr) then
			M.attach(bufnr)
		end
	end
end

return M
