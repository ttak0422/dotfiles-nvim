local cmp = require("cmp")
local luasnip = require("luasnip")
local lspkind = require("lspkind")

lspkind.setup({
	symbol_map = {
		Text = "󰉿",
		Method = "󰊕",
		Function = "󰊕",
		Constructor = "󰒓",
		Field = "󰜢",
		Variable = "󰀫",
		Class = "󰠱",
		Interface = "",
		Module = "",
		Property = "󰜢",
		Unit = "",
		Value = "󰎠",
		Enum = "",
		Keyword = "󰌋",
		Snippet = "",
		Color = "󰏘",
		File = "󰈔",
		Reference = "󰈇",
		Folder = "󰉋",
		EnumMember = "",
		Constant = "󰏿",
		Struct = "󰙅",
		Event = "",
		Operator = "󰆕",
		TypeParameter = "󰗴",
	},
})

cmp.setup({
	cmp.setup({
		snippet = {
			expand = function(args)
				require("luasnip").lsp_expand(args.body)
			end,
		},
		window = {
			completion = cmp.config.window.bordered(),
			documentation = cmp.config.window.bordered(),
		},
		mapping = cmp.mapping.preset.insert({
			["<C-b>"] = cmp.mapping.scroll_docs(-4),
			["<C-f>"] = cmp.mapping.scroll_docs(4),
			["<C-Space>"] = cmp.mapping.complete(),
			["<C-p>"] = cmp.mapping.select_prev_item(),
			["<C-n>"] = cmp.mapping.select_next_item(),
			["<C-e>"] = cmp.mapping.abort(),
			["<C-y>"] = cmp.mapping.confirm({ select = false }),
			["<CR>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					if luasnip.expandable() then
						luasnip.expand()
					else
						cmp.confirm({
							select = true,
						})
					end
				else
					fallback()
				end
			end),
			["<Tab>"] = cmp.mapping(function(fallback)
				if luasnip.locally_jumpable(1) then
					luasnip.jump(1)
				else
					fallback()
				end
			end, { "i", "s" }),
			["<S-Tab>"] = cmp.mapping(function(fallback)
				if luasnip.locally_jumpable(-1) then
					luasnip.jump(-1)
				else
					fallback()
				end
			end, { "i", "s" }),
			["<C-x>f"] = function()
				cmp.complete({
					config = {
						sources = {
							{ name = "path" },
						},
					},
				})
			end,
			["<C-x>l"] = function()
				cmp.complete({
					config = {
						sources = {
							{ name = "nvim_lsp" },
						},
					},
				})
			end,
		}),
		sources = cmp.config.sources({
			{ name = "nvim_lsp" },
			{ name = "luasnip" },
		}, {
			{ name = "buffer" },
		}),
		formatting = {
			format = lspkind.cmp_format({
				mode = "symbol",
				maxwidth = 50,
				ellipsis_char = "...",
			}),
		},
	}),
})

cmp.setup.cmdline({ "/", "?" }, {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{ name = "buffer" },
	},
})

cmp.setup.cmdline(":", {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{ name = "path" },
	}, {
		{ name = "cmdline" },
	}),
	matching = { disallow_symbol_nonprefix_matching = false },
})

vim.cmd([[
cnoremap <expr> <C-a> '<Home>'
cnoremap <expr> <C-e> '<End>'
cnoremap <expr> <C-b> '<Left>'
cnoremap <expr> <C-f> '<Right>'
]])
