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
  extraPackages = [
    pkgs.jq
    pkgs.git
  ]
  ++ packages.configurations.extraPackages;
  plugins = packages.configurations.plugins ++ [
    (
      packages.core.definition
      // {
        dependPlugins = with packages.configurations.definitions; [
          snacks-nvim
          sorairo
          nvim-config-local
        ];
        preConfig = packages.configurations.editorPreConfig;
        config = packages.configurations.editorConfig + "\n" + packages.core.definition.config;
        doc = packages.core.definition.doc + ''

          Migration baseline: main at bea6cafa (v2/default). All enabled
          groups, including their recursive dependencies, are represented in
          v3/packages/configurations. Plugin pins were refreshed against their
          configured branches or release streams during migration (36 updated).
          Goda SKK keeps the latest released v0.7.2/v0.3.3 pair. v3 has separate
          nixpkgs, pterm and track inputs; the existing v2 lock entries remain
          unchanged. The shared meian, mimori and mcp-hub flake inputs already
          match upstream HEAD and are reused. Bespoke Java/Kotlin/JDK recipes
          retain their tested releases; v3 Neovim and JDTLS now use current
          nixpkgs recipes without the older v2 overrides. Configuration, templates and helper modules
          are owned under v3; no v2 configuration file is loaded at runtime.
          The original Fennel configurations are manually ported to readable
          Lua rather than embedding compiler output. v2 configuration and pin
          revisions/hashes, and README are unchanged. The shared npins helper
          only uses GitHub's official archive host; package outputs are identical.

          Plugins with enabled v2 command hooks load lazily from their commands.
          Required module, key and native event entry points remain available.
          Other plugins remain eager; this does not restore old timing-only groups.
          Native filetype behavior, such as Java/Kotlin attachment and
          SFCC's JavaScript-only gf mapping, remains scoped to the matching
          buffer. Completion and Telescope each use one packages unit for their
          engine and dedicated extensions, with shared configuration, docs and
          tests. Other plugins remain individual definitions. dependPlugins
          describes real requirements, not historical loading events or command
          groups. Each packages unit is declared once as its engine package's
          dependency; consumers reference real member packages, ensuring shared
          setup completes first without replaying it.
          Owned editor options, mappings and terminal/Gitu helpers are separate
          configuration modules, not fake plugin packages.

          Excluded: denops.vim, gin.vim, vim-mr, telescope-mr, skkeleton and
          skkeleton-henkan-highlight, plus actually-doom.nvim and Codewindow at the
          user's request. Their plugins, source pins, dedicated build/patch and
          minimap keymap are removed.
          The Gin abbreviation and MR mappings
          and extension are removed. Telescope and terminal-popup SKK now
          use Goda. Deno remains available for denols; Go remains available
          for Go tooling. The cmp_luasnip bridge and the configured
          Git/RuboCop/curl executables are explicit dependencies, fixing
          missing v2 runtime requirements.

          Startup compatibility: Videre round_units=false
          becomes box_style= "sharp"; the removed simple_statusline option
          has no upstream equivalent. Goda uses unmodified upstream scripts;
          popup checks verify actual input, send/cancel, restored state and
          visible errors rather than treating an intentionally suppressed
          internal cleanup diagnostic as a user-visible failure. Meian's
          macOS defaults executable is available through the wrapper's
          /usr/bin PATH fallback, after existing Nix tools. Kitty image
          initialization waits for UIEnter if a remote UI attaches later,
          and stays disabled in Neovide.
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
          build-logs. Inline tests cover startup, cmp sources, live Lua LSP
          diagnostics, native filetypes, parsers, terminal popup
          send/cancel, and actual Goda conversion/learning across restarts.
        '';
      }
    )
  ];
}
