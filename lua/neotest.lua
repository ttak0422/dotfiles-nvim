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
  floating = {
    border = "none",
    max_height = 0.6,
    max_width = 0.6,
    options = {},
  },
})

for _, c in ipairs({
  {
    "Neotest",
    "lua require('neotest').run.run(vim.fn.expand('%'))",
  },
  { "NeotestStop",          "lua require('neotest').run.stop()" },
  { "NeotestNearest",       "lua require('neotest').run.run({strategy='dap'})" },
  { "NeotestCurrentFile",   "lua require('neotest').run.run(vim.fn.expand('%'))" },
  { "NeotestAllFile",       "lua require('neotest').run.run(vim.loop.cwd())" },
  { "NeotestToggleSummary", "lua require('neotest').summary.toggle()" },
  { "NeotestTogglePanel",   "lua require('neotest').output_panel.toggle()" },
}) do
  vim.api.nvim_create_user_command(c[1], c[2], {})
end
