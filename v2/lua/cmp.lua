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
		["<C-p>"] = cmp.mapping.select_prev_item(),
		["<C-n>"] = cmp.mapping.select_next_item(),
		["<C-e>"] = cmp.mapping.abort(),
		["<C-y>"] = cmp.mapping.confirm({ select = true }),
		["<CR>"] = cmp.mapping(function(fallback)
			if cmp.visible() and cmp.get_active_entry() then
				if luasnip.expandable() then
					luasnip.expand()
				else
					cmp.confirm({
						select = false,
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
})

-- Cycle through candidates while applying each one. The first <Tab> opens the
-- menu and immediately selects/inserts the first candidate (cmdline sources are
-- synchronous, so entries are available right after cmp.complete()).
local function cmdline_select(select)
	return {
		c = function()
			if not cmp.visible() then
				cmp.complete()
			end
			if cmp.visible() then
				select({ behavior = cmp.SelectBehavior.Insert })
			end
		end,
	}
end

local cmdline_mapping = cmp.mapping.preset.cmdline({
	["<Tab>"] = cmdline_select(cmp.select_next_item),
	["<S-Tab>"] = cmdline_select(cmp.select_prev_item),
})

cmp.setup.cmdline({ "/", "?" }, {
	mapping = cmdline_mapping,
	sources = {
		{ name = "buffer" },
	},
})

cmp.setup.cmdline(":", {
	mapping = cmdline_mapping,
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
