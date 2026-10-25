{ pkgs }:
{
  gitcommit =
    pkgs.runCommand "gitcommit-ticket-prefix-tests"
      {
        nativeBuildInputs = [
          pkgs.neovim-unwrapped
          pkgs.git
        ];
        NFNL_PLUGIN_DIR = pkgs.vimPlugins.v2.nfnl;
      }
      ''
        cp -R ${../.} source
        chmod -R u+w source
        cd source
        export HOME="$TMPDIR/home"
        mkdir -p "$HOME"
        nvim -n --headless -u NONE -i NONE -l tests/gitcommit.lua
        touch "$out"
      '';

  idea-format =
    pkgs.runCommand "idea-format-tests"
      {
        nativeBuildInputs = [
          pkgs.neovim-unwrapped
          pkgs.google-java-format
        ];
        IDEA_TEST_SHELL = pkgs.runtimeShell;
        NONE_LS_PLUGIN_DIR = pkgs.vimPlugins.v2.none-ls-nvim;
        NFNL_PLUGIN_DIR = pkgs.vimPlugins.v2.nfnl;
        PLENARY_PLUGIN_DIR = pkgs.vimPlugins.v2.plenary-nvim;
      }
      ''
        cp -R ${../.} source
        chmod -R u+w source
        cd source
        export HOME="$TMPDIR/home"
        mkdir -p "$HOME"
        nvim -n --headless -u NONE -i NONE -l tests/idea-format.lua
        touch "$out"
      '';

  lsp-attach =
    pkgs.runCommand "lsp-attach-tests"
      {
        nativeBuildInputs = [ pkgs.neovim-unwrapped ];
        NFNL_PLUGIN_DIR = pkgs.vimPlugins.v2.nfnl;
      }
      ''
        cp -R ${../.} source
        chmod -R u+w source
        cd source
        export HOME="$TMPDIR/home"
        mkdir -p "$HOME"
        nvim -n --headless -u NONE -i NONE -l tests/lsp-attach.lua
        touch "$out"
      '';

  hud =
    pkgs.runCommand "hud-config-tests"
      {
        nativeBuildInputs = [
          pkgs.neovim-unwrapped
          pkgs.git
        ];
        HUD_TEST_PLUGIN = pkgs.vimPlugins.v2.hud-nvim;
        HUD_TEST_GITSIGNS = pkgs.vimPlugins.v2.gitsigns-nvim;
        HUD_TEST_THEME = pkgs.vimPlugins.v2.sorairo;
      }
      ''
        cp -R ${../.} source
        chmod -R u+w source
        cd source
        export HOME="$TMPDIR/home"
        mkdir -p "$HOME"
        nvim -n --headless -u NONE -i NONE -l tests/hud.lua
        touch "$out"
      '';

  workflows = pkgs.runCommand "workflow-lint" { nativeBuildInputs = [ pkgs.actionlint ]; } ''
    actionlint ${../.github/workflows/flake-check.yml}
    touch "$out"
  '';

  code-action =
    pkgs.runCommand "code-action-tests"
      {
        nativeBuildInputs = [
          pkgs.neovim-unwrapped
          pkgs.delta
        ];
        CODE_ACTION_TEST_TINY = pkgs.vimPlugins.v2.tiny-code-action-nvim;
        CODE_ACTION_TEST_TELESCOPE = pkgs.vimPlugins.v2.telescope-nvim;
        CODE_ACTION_TEST_PLENARY = pkgs.vimPlugins.v2.plenary-nvim;
        CODE_ACTION_TEST_LSPCONFIG = pkgs.vimPlugins.v2.nvim-lspconfig;
      }
      ''
        cp -R ${../.} source
        chmod -R u+w source
        cd source
        export HOME="$TMPDIR/home"
        mkdir -p "$HOME"
        nvim --headless -u NONE -i NONE -l tests/code-action.lua
        CODE_ACTION_TEST_CASE=buffer nvim --headless -u NONE -i NONE -l tests/code-action.lua
        touch "$out"
      '';

  checkmake =
    pkgs.runCommand "checkmake-config-tests"
      {
        nativeBuildInputs = [
          pkgs.neovim-unwrapped
          pkgs.checkmake
        ];
        CHECKMAKE_TEST_SHELL = pkgs.runtimeShell;
        NONE_LS_PLUGIN_DIR = pkgs.vimPlugins.v2.none-ls-nvim;
        NFNL_PLUGIN_DIR = pkgs.vimPlugins.v2.nfnl;
        PLENARY_PLUGIN_DIR = pkgs.vimPlugins.v2.plenary-nvim;
      }
      ''
        cp -R ${../.} source
        chmod -R u+w source
        cd source
        export HOME="$TMPDIR/home"
        mkdir -p "$HOME"
        nvim --headless -u NONE -i NONE -l tests/checkmake.lua
        touch "$out"
      '';

  terminal =
    pkgs.runCommand "terminal-picker-tests"
      {
        nativeBuildInputs = [ pkgs.python3 ];
        TERMINAL_TEST_NVIM = "${pkgs.neovim-unwrapped}/bin/nvim";
        TERMINAL_TEST_PTERM = "${pkgs.vimPlugins.v2.pterm-daemon}/bin/pterm";
        TERMINAL_TEST_PTERM_PLUGIN = pkgs.vimPlugins.v2.pterm;
        TERMINAL_TEST_NFNL = pkgs.vimPlugins.v2.nfnl;
        TERMINAL_TEST_TELESCOPE = pkgs.vimPlugins.v2.telescope-nvim;
        TERMINAL_TEST_PLENARY = pkgs.vimPlugins.v2.plenary-nvim;
        TERMINAL_TEST_LIVE_GREP_ARGS = pkgs.vimPlugins.v2.telescope-live-grep-args-nvim;
      }
      ''
        cp -R ${../.} source
        chmod -R u+w source
        cd source
        patchShebangs tests/terminal/child.py
        python3 tests/terminal/run.py
        touch "$out"
      '';

  mimori =
    pkgs.runCommand "mimori-tests"
      {
        nativeBuildInputs = [
          pkgs.python3
          pkgs.neovim-unwrapped
        ];
        MIMORI_TEST_NVIM = "${pkgs.neovim-unwrapped}/bin/nvim";
        MIMORI_KOMADO = pkgs.vimPlugins.v2.komado-nvim;
      }
      ''
        cp -R ${../.} source
        chmod -R u+w source
        cd source
        patchShebangs tests/mimori/fake-cli.py
        python3 tests/mimori/run.py
        touch "$out"
      '';
}
// pkgs.lib.optionalAttrs (pkgs.stdenv.hostPlatform.system == "aarch64-darwin") {
  kotlin-config =
    pkgs.runCommand "kotlin-config-tests"
      {
        nativeBuildInputs = [ pkgs.neovim-unwrapped ];
        KOTLIN_PLUGIN_DIR = pkgs.vimPlugins.v2.kotlin-nvim;
        KOTLIN_LSP_DIR = "${pkgs.v2.kotlin-lsp}/libexec/kotlin-lsp";
        NFNL_PLUGIN_DIR = pkgs.vimPlugins.v2.nfnl;
      }
      ''
        cp -R ${../.} source
        chmod -R u+w source
        cd source
        export XDG_STATE_HOME="$TMPDIR/state" XDG_CACHE_HOME="$TMPDIR/cache" XDG_DATA_HOME="$TMPDIR/data"
        nvim --headless -u NONE -i NONE -l tests/kotlin-config.lua
        touch "$out"
      '';
}
