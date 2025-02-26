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
    fennel = read ../lua/autogen/after/fennel.lua;
    gitcommit = read ../lua/autogen/after/gitcommit.lua;
    nix = read ../lua/autogen/after/nix.lua;
    qf = {
      language = "vim";
      code = read ../vim/after/qf.vim;
    };
    qfreplace = {
      language = "vim";
      code = read ../vim/after/qfreplace.vim;
    };
    gina-blame = {
      language = "vim";
      code = read ../vim/after/gina-blame.vim;
    };
    cabal = hashkellTools;
    cabalproject = hashkellTools;
    cagbal = hashkellTools;
    lhaskell = hashkellTools;
    haskell = hashkellTools;
    yaml = read ../lua/autogen/after/yaml.lua;
    jproperties = read ../lua/autogen/after/jproperties.lua;
    make = read ../lua/autogen/after/make.lua;
    go = read ../lua/autogen/after/go.lua;
    rust = ''
      -- Hack: load rustaceanvim before setup
      require("rustaceanvim")
      dofile("${pkgs.vimPlugins.rustaceanvim}/ftplugin/rust.lua")
    '';
    java =
      let
        inherit (pkgs.vscode-marketplace.vscjava) vscode-java-debug vscode-java-test;
        jdtls = pkgs.pkgs-nightly.jdt-language-server;
      in
      {
        code = read ../lua/autogen/after/java.lua;
        args = {
          java_path = "${pkgs.jdk}/bin/java";
          # java23_path = "${pkgs.jdk23}/bin/java";
          # java17_path = "${pkgs.jdk17}/bin/java";
          jdtls_config_path =
            let
              systemPath = if pkgs.stdenv.isDarwin then "config_mac" else "config/linux";
            in
            "${jdtls}/share/java/jdtls/${systemPath}";
          lombok_jar_path = "${pkgs.lombok}/share/java/lombok.jar";
          jdtls_jar_pattern = "${jdtls}/share/java/jdtls/plugins/org.eclipse.equinox.launcher_*.jar";
          java_debug_jar_pattern = "${vscode-java-debug}/share/vscode/extensions/vscjava.vscode-java-debug/server/com.microsoft.java.debug.plugin-*.jar";
          java_test_jar_pattern = "${vscode-java-test}/share/vscode/extensions/vscjava.vscode-java-test/server/*.jar";
          jol_jar_path = pkgs.javaPackages.jol;
          capabilities_path = ../lua/autogen/capabilities.lua;
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
        setlocal cursorline
      '';
    };
    NeogitCommitView = {
      language = "vim";
      code = ''
        setlocal foldcolumn=0
        setlocal cursorline
      '';
    };
    NeogitDiffView = {
      language = "vim";
      code = ''
        setlocal foldcolumn=0
        setlocal cursorline
      '';
    };
    json = readVim ../vim/after/json.vim;
    help = read "${pkgs.vimPlugins.helpview-nvim}/ftplugin/help.lua";
  };

  ftdetect = {
    nginx = {
      language = "vim";
      code = ''
        source ${pkgs.vimPlugins.nginx-vim}/ftdetect/nginx.vim
        au BufRead,BufNewFile *.nginxconf set ft=nginx
      '';
    };
    kbd = {
      language = "vim";
      code = "au BufRead,BufNewFile *.kbd set filetype=kbd";
    };
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
