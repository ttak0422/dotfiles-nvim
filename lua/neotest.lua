require("neotest").setup({
	adapters = {
		require("neotest-python")({
			dap = { justMyCode = false },
		}),
		require("neotest-plenary"),
		require("neotest-golang")({
			go_test_args = {
				"-v",
				"-race",
				"-count=1",
				"-timeout=60s",
				"-coverprofile=" .. vim.fn.getcwd() .. "/coverage.out",
			},
		}),
		require("neotest-jest")({
			jestCommand = "npm test --",
			jestConfigFile = "custom.jest.config.ts",
			env = { CI = true },
			cwd = function(path)
				return vim.fn.getcwd()
			end,
		}),
		require("neotest-vitest"),
		require("neotest-playwright").adapter({
			options = {
				persist_project_selection = true,
				enable_dynamic_test_discovery = true,
				preset = "none",
				get_playwright_binary = function()
					return vim.loop.cwd() .. "/node_modules/.bin/playwright"
				end,
				get_playwright_config = function()
					return vim.loop.cwd() .. "/playwright.config.ts"
				end,
				get_cwd = function()
					return vim.loop.cwd()
				end,
				env = {},
				extra_args = {},
				filter_dir = function(name, rel_path, root)
					return name ~= "node_modules"
				end,
				-- is_test_file = function(file_path)
				--   local result = file_path:find("%.test%.[tj]sx?$") ~= nil
				--       or file_path:find("%.spec%.tjsx?$") ~= nil
				--   -- Alternative example: Match only files that end in `test.ts`
				--   local result = file_path:find("%.test%.ts$") ~= nil
				--   -- Alternative example: Match only files that end in `test.ts`, but only if it has ancestor directory `e2e/tests`
				--   local result = file_path:find("e2e/tests/.*%.test%.ts$") ~= nil
				--   return result
				-- end,
				experimental = {
					telescope = {
						enabled = false,
						opts = {},
					},
				},
			},
		}),
		require("neotest-rspec"),
		require("neotest-minitest"),
		require("neotest-dart")({
			command = "flutter",
			use_lsp = true,
			custom_test_method_names = {},
		}),
		require("neotest-rust"),
		require("neotest-elixir"),
		require("neotest-dotnet"),
		require("neotest-scala"),
		require("neotest-haskell"),
		require("neotest-deno"),
		require("neotest-java")({
			junit_jar = args.junit_jar_path,
		}),
		require("neotest-vim-test")({
			allow_file_types = {},
		}),
	},
	default_strategy = "integrated",
	floating = {
		border = "none",
		max_height = 0.6,
		max_width = 0.6,
		options = {},
	},
	icons = {
		child_indent = "│",
		child_prefix = "├",
		collapsed = "─",
		expanded = "╮",
		failed = "",
		final_child_indent = " ",
		final_child_prefix = "╰",
		non_collapsible = "─",
		notify = "",
		passed = "",
		running = "",
		running_animated = {
			"⠋",
			"⠙",
			"⠹",
			"⠸",
			"⠼",
			"⠴",
			"⠦",
			"⠧",
			"⠇",
			"⠏",
		},
		skipped = "",
		unknown = "",
		watching = "",
	},
	quickfix = {
		enabled = true,
		open = false,
	},
	discovery = {
		enabled = false,
		concurrent = 1,
	},
	running = {
		concurrent = true,
	},
	summary = {
		animated = false,
		mappings = {
			attach = "a",
			clear_marked = "M",
			clear_target = "T",
			debug = "d",
			debug_marked = "D",
			expand = { "<CR>", "<2-LeftMouse>" },
			expand_all = "e",
			help = "g?",
			jumpto = "i",
			mark = "m",
			next_failed = "J",
			output = "o",
			prev_failed = "K",
			run = "r",
			run_marked = "R",
			short = "O",
			stop = "u",
			target = "t",
			watch = "w",
		},
	},
})

for _, c in ipairs({
	{ "Neotest",              "lua require('neotest').run.run(vim.fn.expand('%'))" },
	{ "NeotestStop",          "lua require('neotest').run.stop()" },
	{ "NeotestNearest",       "lua require('neotest').run.run()" },
	{ "NeotestAllFile",       "lua require('neotest').run.run(vim.loop.cwd())" },
	{ "NeotestToggleSummary", "lua require('neotest').summary.toggle()" },
	{ "NeotestTogglePanel",   "lua require('neotest').output_panel.toggle()" },
	{ "NeotestOpenOutput",    "lua require('neotest').output.open({ enter = true })" },
}) do
	vim.api.nvim_create_user_command(c[1], c[2], {})
end
