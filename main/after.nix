{ pkgs, ... }:
let
  read = builtins.readFile;
  readVim = path: {
    language = "vim";
    code = read path;
  };
  plugin = {
    common = {
      language = "vim";
      code = read ../vim/after/common-plugin.vim;
    };
  };

  hashkellTools = ''
    dofile("${pkgs.vimPlugins.haskell-tools-nvim}/ftplugin/haskell.lua")
  '';
  ftplugin = {
    qf = {
      language = "vim";
      code = read ../vim/after/qf.vim;
    };
    gina-blame = {
      language = "vim";
      code = read ../vim/after/gina-blame.vim;
    };
    cabal = hashkellTools;
    cabalproject = hashkellTools;
    cagbal = hashkellTools;
    lhaskell = hashkellTools;
    rust = ''
      -- Hack: load rustaceanvim before setup
      require("rustaceanvim")
      dofile("${pkgs.vimPlugins.rustaceanvim}/ftplugin/rust.lua")
    '';
    java =
      let
        inherit (pkgs.vscode-marketplace.vscjava) vscode-java-debug vscode-java-test;
        jdtls = pkgs.jdt-language-server;
      in
      {
        code = read ../lua/autogen/after/java.lua;
        args = {
          on_attach_path = ../lua/autogen/lsp-on-attach.lua;
          capabilities_path = ../lua/autogen/ddc-capabilities.lua;
          java_path = "${pkgs.jdk17}/bin/java";
          java22_path = "${pkgs.jdk22}/bin/java";
          java17_path = "${pkgs.jdk17}/bin/java";
          jdtls_config_path =
            let
              systemPath = if pkgs.stdenv.isDarwin then "config_mac" else "config/linux";
            in
            "${jdtls}/share/java/jdtls/${systemPath}";
          lombok_jar_path = "${pkgs.pkgs-stable.lombok}/share/java/lombok.jar";
          jdtls_jar_pattern = "${jdtls}/share/java/jdtls/plugins/org.eclipse.equinox.launcher_*.jar";
          java_debug_jar_pattern = "${vscode-java-debug}/share/vscode/extensions/vscjava.vscode-java-debug/server/com.microsoft.java.debug.plugin-*.jar";
          java_test_jar_pattern = "${vscode-java-test}/share/vscode/extensions/vscjava.vscode-java-test/server/*.jar";
          jol_jar_path = pkgs.javaPackages.jol;
        };
      };
    norg = read ../lua/autogen/after/norg.lua;
    ddu-ff = {
      language = "vim";
      code = read ../vim/after/ddu-ui-ff.vim;
    };
    NeogitStatus = {
      language = "vim";
      code = ''
        setlocal foldcolumn=0
      '';
    };
    NeogitCommitView = {
      language = "vim";
      code = ''
        setlocal foldcolumn=0
      '';
    };
    NeogitDiffView = {
      language = "vim";
      code = ''
        setlocal foldcolumn=0
      '';
    };
    json = readVim ../vim/after/json.vim;
    help = read "${pkgs.vimPlugins.helpview-nvim}/ftplugin/help.lua";
  };

  ftdetect = {
    # MEMO: 重いので有効化しない
    # log = {
    #   language = "vim";
    #   code = ''
    #     au BufNewFile,BufRead  *{.,_}log  set filetype=log
    #   '';
    # };
  };
in
{
  inherit plugin ftplugin ftdetect;
}
