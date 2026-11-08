{
  pkgs,
  lib,
  sources,
  definitions,
  luaConfig,
  emptyPlugin,
  inputs',
}:
with sources;
with definitions;
let
  ideaContents = "${pkgs.jetbrains.idea}/Applications/${pkgs.jetbrains.idea.desktopName}.app/Contents";
in
{
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
        go-tools # Go
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
  dependPlugins = [ plenary ];
  config = luaConfig ({
    code = # lua
      ''
        local null_ls = require("null-ls")
        local diagnostics = null_ls.builtins.diagnostics
        local formatting = null_ls.builtins.formatting
        local utils = require("null-ls.utils")
        local helpers = require("null-ls.helpers")
        local idea = dofile(args.idea_formatter_path)
        local checkmake
        local function _1_(opts)
          local parse_line = opts.on_output
          local raw_opts = vim.deepcopy(opts)
          raw_opts.format = "raw"
          raw_opts.check_exit_code = {0, 1}
          local function _2_(params, done)
            local count = (params.err and string.match(params.err, "^Error: violations found %(([1-9]%d*)%)\n?$"))
            if (params.err and not count) then
              error(params.err)
            else
            end
            local results = {}
            for _, line in ipairs(vim.split(string.gsub((params.output or ""), "\r\n?", "\n"), "\n")) do
              if (line ~= "") then
                local diagnostic = parse_line(line, params)
                if diagnostic then
                  table.insert(results, diagnostic)
                else
                end
              else
              end
            end
            if (count and (tonumber(count) ~= #results)) then
              error(params.err)
            else
            end
            return done(results)
          end
          raw_opts.on_output = _2_
          return helpers.generator_factory(raw_opts)
        end
        checkmake = diagnostics.checkmake.with({factory = _1_})
        vim.g.idea_path = args.idea
        local sources
        local function _7_()
          return (vim.g.checkstyle ~= nil)
        end
        local function _8_(ps)
          return (ps.bufname ~= "")
        end
        local function _9_()
          return (vim.g.idea_format == nil)
        end
        local function _10_()
          return (vim.g.idea_format == nil)
        end
        local function _11_(_241)
          return (utils.root_pattern({"tsconfig.json", "package.json", "jsconfig.json", ".node_project"})(_241.bufname) and not utils.root_pattern({"rome.json", "biome.json", "biome.jsonc"})(_241.bufname))
        end
        local function _12_(_241)
          return utils.root_pattern({"rome.json", "biome.json", "biome.jsonc"})(_241.bufname)
        end
        sources = {diagnostics.actionlint, checkmake, diagnostics.checkstyle.with({runtime_condition = _7_, extra_args = {"-c", (vim.g.checkstyle or "/google_checks.xml")}}), diagnostics.deadnix, diagnostics.dotenv_linter.with({args = {"check", "--plain", "$FILENAME"}}), diagnostics.editorconfig_checker.with({runtime_condition = _8_}), diagnostics.gitlint, diagnostics.ktlint, diagnostics.mypy, diagnostics.selene, diagnostics.semgrep, diagnostics.sqruff, diagnostics.staticcheck, diagnostics.statix, diagnostics.stylelint, diagnostics.terraform_validate, diagnostics.vint, diagnostics.yamllint, formatting.fantomas, formatting.fnlfmt, formatting.gofumpt, formatting.goimports, formatting.ktlint.with({runtime_condition = _9_}), formatting.nixfmt, formatting.shfmt, formatting.sqruff, formatting.stylelint, formatting.stylua, formatting.terraform_fmt, formatting.tidy, formatting.yamlfmt, formatting.yapf, idea(args), formatting.google_java_format.with({runtime_condition = _10_, timeout = 20000}), formatting.prettier.with({prefer_local = "node_modules/.bin", runtime_condition = helpers.cache.by_bufnr(_11_), filetypes = {"javascript", "javascriptreact", "typescript", "typescriptreact", "vue", "css", "scss", "less", "graphql", "handlebars", "svelte", "astro", "htmlangular"}}), formatting.biome.with({runtime_condition = helpers.cache.by_bufnr(_12_), filetypes = {"javascript", "typescript", "javascriptreact", "typescriptreact", "css", "graphql"}})}
        null_ls.setup({border = "single", cmd = {"nvim"}, debounce = 300, default_timeout = 10000, diagnostic_config = {}, diagnostics_format = "#{m} (#{s})", fallback_severity = vim.diagnostic.severity.ERROR, log_level = "warn", notify_format = "[null-ls] %s", on_attach = nil, on_init = nil, on_exit = nil, root_dir = utils.root_pattern({".null-ls-root", ".git"}), root_dir_async = nil, should_attach = nil, temp_dir = nil, sources = sources, debug = false, update_in_insert = false})
        local function _13_()
          return vim.cmd("NullLsInfo")
        end
        vim.api.nvim_create_user_command("NoneLsInfo", _13_, {})
        local function _14_()
          return vim.cmd("NullLsLog")
        end
        return vim.api.nvim_create_user_command("NoneLsLog", _14_, {})
      '';
    args = {
      # Darwin's bin/idea uses open; formatting needs the native process/status.
      idea = "${ideaContents}/MacOS/idea";
      idea_vm_options = "${ideaContents}/bin/idea.vmoptions";
      idea_formatter_path = ../support/idea-format.lua;
    };
  });
  doc = "Enabled v2/default none-ls configuration, loaded at startup. See the migration inventory in the core cartridge documentation.";
}
