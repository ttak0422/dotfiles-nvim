{ pkgs, inputs' }:
let
  packages = import ../packages { inherit pkgs inputs'; };
in
{
  startupConfig = ''
    vim.o.termguicolors = true
    -- Fyler clears netrw's group even when netrw is disabled before startup.
    vim.api.nvim_create_augroup("FileExplorer", { clear = false })
    vim.g.python3_host_prog = "${pkgs.python3.withPackages (ps: [ ps.pynvim ])}/bin/python3"
    ${packages.core.startupConfig}
  '';
  runtimePaths = [ packages.core.runtime ];
  extraPackages = [
    pkgs.jq
    pkgs.git
  ];
  plugins = [
    (
      packages.core.definition
      // {
        dependPlugins = packages.configurations.plugins ++ [ packages.skk ];
        doc = packages.core.definition.doc + ''

          Migration baseline: main at bea6cafa (v2/default). All enabled
          groups, including their recursive dependencies, are represented in
          v3/packages/configurations. The 168 selected v2 npins entries
          retain their exact revisions and hashes; Goda SKK keeps its
          existing pins. Configuration, templates and helper modules are
          owned under v3. v2 and README are unchanged. The new cartridges do
          not read v2 configuration files; existing shared package overlays
          and locked inputs are reused.

          Every plugin is eager. There are no lazy flags or loader triggers.
          Native filetype behavior, such as Java/Kotlin attachment and
          SFCC's JavaScript-only gf mapping, remains scoped to the matching
          buffer. Group cartridges keep common configuration after their
          dependencies; repeated plugin occurrences are merged by divine and
          configured once.

          Excluded: denops.vim, gin.vim, vim-mr, telescope-mr, skkeleton and
          skkeleton-henkan-highlight. The Gin abbreviation and MR mappings
          and extension are removed. Telescope and terminal-popup SKK now
          use Goda. Deno remains available for denols; Go remains available
          for Go tooling. The cmp_luasnip bridge and the configured
          Git/RuboCop/curl executables are explicit dependencies, fixing
          missing v2 runtime requirements.

          Startup compatibility: Codewindow's pinned source is patched to
          use Neovim's core Treesitter query/range APIs, with a real
          highlighted minimap regression test. Videre round_units=false
          becomes box_style= "sharp"; the removed simple_statusline option
          has no upstream equivalent. Goda's buffer cleanup uses idempotent
          unlet! so closing a terminal input popup cannot leave an E716
          error after InsertLeave already restored it. Kitty image
          initialization waits for UIEnter if a remote UI attaches later,
          and stays disabled in Neovide. Plugin loading remains eager.
          Python3 provider support is preserved, and external editor
          fallback starts this same v3 init rather than a bare isolated
          NVIM_APPNAME.

          The complete profile is exported on aarch64-darwin, matching its
          native meian, Kotlin LSP and koe helpers. koe dictation
          additionally requires macOS 26 and microphone permission.
          Graph/evaluation success does not imply Linux support. GUI
          graphics, dictation, authenticated AI tools, external MCP services
          and the separately installed rustowl executable require their real
          runtime environment and are not exercised by offline checks. Eager
          setup can start local helper services at editor startup. Inherited
          Neorg/Avante/notebook bindings remain, but their disabled plugins
          have not been enabled as part of this migration.

          Validation: nix build '.#v3/default'; nix flake check --print-
          build-logs. Inline tests cover source coverage, graph
          timing/Denops exclusion, startup, cmp sources, live Lua LSP
          diagnostics, native filetypes, parsers, minimap, terminal popup
          send/cancel, and actual Goda conversion/learning across restarts.
        '';
        tests = packages.core.definition.tests // {
          migration-graph =
            { pkgs, bundle, ... }:
            let
              nodes = builtins.attrValues bundle.graph.nodes;
              pluginPaths = map (node: toString node.package) nodes;
              missing = builtins.filter (name: !(builtins.elem (toString packages.sources.${name}) pluginPaths)) (
                builtins.attrNames packages.sources
              );
              # These sources are deliberately rebuilt/filtered, or used as tools.
              expectedMissing = [
                "goda-skk-vim"
                "goda-vim"
                "nginx-vim"
                "nvim-lspconfig"
                "pterm-daemon"
                "tiny-code-action-nvim"
                "track-cli"
              ];
              toolPaths = map toString bundle.graph.extraPackages;
              forbidden = [
                "denops"
                "gin-vim"
                "vim-mr"
                "telescope-mr"
                "skkeleton"
              ];
              noDenops =
                node: !(pkgs.lib.any (name: pkgs.lib.hasInfix name (pkgs.lib.getName node.package)) forbidden);
              eager =
                node:
                !node.settings.lazy
                && pkgs.lib.all (name: (node.settings.${name} or [ ]) == [ ]) [
                  "onEvents"
                  "onCommands"
                  "onFiletypes"
                  "onKeys"
                  "onModules"
                ];
            in
            assert missing == expectedMissing;
            assert builtins.elem (toString packages.sources.pterm-daemon) toolPaths;
            assert builtins.elem (toString packages.sources.track-cli) toolPaths;
            assert pkgs.lib.all eager nodes;
            assert pkgs.lib.all noDenops nodes;
            pkgs.writeText "v3-migration-graph.json" (
              builtins.toJSON (
                map (node: {
                  name = pkgs.lib.getName node.package;
                  inherit (node) dependencies;
                }) nodes
              )
            );
        };
      }
    )
  ];
}
