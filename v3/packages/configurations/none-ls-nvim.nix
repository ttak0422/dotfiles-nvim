{
  pkgs,
  lib,
  sources,
  definitions,
  luaConfig,
  luaCheck,
  inputs',
}:
with sources;
let
  ideaContents = "${pkgs.jetbrains.idea}/Applications/${pkgs.jetbrains.idea.desktopName}.app/Contents";
in
{
  doc = ''
    # none-ls.nvim

    ## 概要
    外部ツールや Lua の処理結果を Neovim の LSP 機能に接続する、null-ls.nvim の継続版。

    ## 主な機能
    - 診断、整形、コードアクション、hover、補完のソースを提供。
    - 既存 API は `null-ls` の名前を継続。

    ## 使い方
    `require("null-ls").setup({ sources = { ... } })` に利用する builtins を登録する。README の追加ソース例には別途 none-ls-extras.nvim を要するものがあり、この定義で有効とは限らない。

    ## 要件
    README は最新 stable Neovim を開発・テスト対象とし、HEAD は best-effort としている。導入例は plenary.nvim を依存に指定する。外部実行ファイルは選択するソースに依存。

    ## 出典
    [固定リビジョンの README](https://github.com/nvimtools/none-ls.nvim/blob/0b281893e36fe147077b49f022bf9cd78af3ad12/README.md)
  '';
  plugin = sources.none-ls-nvim;
  extraPackages =
    with pkgs;
    # diagnostics
    [
      actionlint # GitHub Actions
      checkmake # Makefile
      checkstyle # Java
      deadnix # Nix
      dotenv-linter # .env
      editorconfig-checker # .editorconfig
      gitlint # Git
      go-tools # Go (staticcheck)
      hadolint # Dockerfile
      ktlint # Kotlin
      mypy
      selene # Lua
      semgrep
      sqruff
      statix # Nix
      stylelint # CSS, SCSS, LESS, SASS
      terraform # Terraform
      vim-vint # Vim script
      yamllint # YAML
    ]
    ++
      # formatters
      [
        biome # WEB
        fantomas # F#
        fnlfmt # Fennel
        gotools # Go (goimports)
        gofumpt # Go
        google-java-format # Java
        html-tidy # HTML
        ktlint # Kotlin
        nixfmt # Nix
        prettier # JS, TS, ...
        shfmt # shell
        sqruff
        stylelint # CSS, SCSS, LESS, SASS
        stylua # Lua
        terraform # Terraform
        yamlfmt # YAML
        yapf # Python
      ];
  dependPlugins = [
    definitions.plenary-nvim
  ];
  config = luaConfig ({
    code = # lua
      ''
        local null_ls = require("null-ls")
        local diagnostics = null_ls.builtins.diagnostics
        local formatting = null_ls.builtins.formatting
        local utils = require("null-ls.utils")
        local helpers = require("null-ls.helpers")
        local idea = dofile(args.idea_formatter_path)

        -- checkmake 0.3 writes diagnostics to stdout and a violation count to stderr.
        -- Accept only a count summary matching the diagnostics parsed by its builtin.
        local checkmake = diagnostics.checkmake.with({
          factory = function(options)
            local parse_line = options.on_output
            local raw_options = vim.deepcopy(options)
            raw_options.format = "raw"
            raw_options.check_exit_code = { 0, 1 }
            raw_options.on_output = function(params, done)
              local count = params.err and params.err:match("^Error: violations found %(([1-9]%d*)%)\n?$")
              if params.err and not count then
                error(params.err)
              end
              local results = {}
              local output = (params.output or ""):gsub("\r\n?", "\n")
              for _, line in ipairs(vim.split(output, "\n")) do
                if line ~= "" then
                  local diagnostic = parse_line(line, params)
                  if diagnostic then
                    table.insert(results, diagnostic)
                  end
                end
              end
              if count and tonumber(count) ~= #results then
                error(params.err)
              end
              done(results)
            end
            return helpers.generator_factory(raw_options)
          end,
        })
        local function use_builtin_formatter()
          return vim.g.idea_format == nil
        end
        local node_root = utils.root_pattern({ "tsconfig.json", "package.json", "jsconfig.json", ".node_project" })
        local biome_root = utils.root_pattern({ "rome.json", "biome.json", "biome.jsonc" })
        vim.g.idea_path = args.idea
        null_ls.setup({
          border = "single",
          cmd = { "nvim" },
          debounce = 300,
          default_timeout = 10000,
          diagnostic_config = {},
          diagnostics_format = "#{m} (#{s})",
          fallback_severity = vim.diagnostic.severity.ERROR,
          log_level = "warn",
          notify_format = "[null-ls] %s",
          root_dir = utils.root_pattern({ ".null-ls-root", ".git" }),
          debug = false,
          update_in_insert = false,
          sources = {
            diagnostics.actionlint,
            checkmake,
            diagnostics.checkstyle.with({
              runtime_condition = function() return vim.g.checkstyle ~= nil end,
              extra_args = { "-c", vim.g.checkstyle or "/google_checks.xml" },
            }),
            diagnostics.deadnix,
            diagnostics.dotenv_linter.with({ args = { "check", "--plain", "$FILENAME" } }),
            diagnostics.editorconfig_checker.with({
              runtime_condition = function(params) return params.bufname ~= "" end,
            }),
            diagnostics.gitlint,
            diagnostics.ktlint,
            diagnostics.mypy,
            diagnostics.selene,
            diagnostics.semgrep,
            diagnostics.sqruff,
            diagnostics.staticcheck,
            diagnostics.statix,
            diagnostics.stylelint,
            diagnostics.terraform_validate,
            diagnostics.vint,
            diagnostics.yamllint,
            formatting.fantomas,
            formatting.fnlfmt,
            formatting.gofumpt,
            formatting.goimports,
            formatting.ktlint.with({ runtime_condition = use_builtin_formatter }),
            formatting.nixfmt,
            formatting.shfmt,
            formatting.sqruff,
            formatting.stylelint,
            formatting.stylua,
            formatting.terraform_fmt,
            formatting.tidy,
            formatting.yamlfmt,
            formatting.yapf,
            idea(args),
            formatting.google_java_format.with({
              runtime_condition = use_builtin_formatter,
              timeout = 20000,
            }),
            formatting.prettier.with({
              prefer_local = "node_modules/.bin",
              runtime_condition = helpers.cache.by_bufnr(function(params)
                return node_root(params.bufname) and not biome_root(params.bufname)
              end),
              filetypes = {
                "javascript", "javascriptreact", "typescript", "typescriptreact",
                "vue", "css", "scss", "less", "graphql", "handlebars", "svelte",
                "astro", "htmlangular",
              },
            }),
            formatting.biome.with({
              runtime_condition = helpers.cache.by_bufnr(function(params)
                return biome_root(params.bufname)
              end),
              filetypes = {
                "javascript", "typescript", "javascriptreact", "typescriptreact", "css", "graphql",
              },
            }),
          },
        })
        vim.api.nvim_create_user_command("NoneLsInfo", function() vim.cmd("NullLsInfo") end, {})
        vim.api.nvim_create_user_command("NoneLsLog", function() vim.cmd("NullLsLog") end, {})
      '';
    args = {
      # Darwin's bin/idea uses open; formatting needs the native process/status.
      idea = "${ideaContents}/MacOS/idea";
      idea_vm_options = "${ideaContents}/bin/idea.vmoptions";
      idea_formatter_path = ../support/idea-format.lua;
    };
  });
  tests.goimports-formatting = luaCheck {
    name = "goimports-formatting";
    script = builtins.readFile ../checks/goimports.lua;
  };
}
