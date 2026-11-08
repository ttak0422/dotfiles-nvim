{ pkgs, inputs' }:
let
  inherit (pkgs) lib stdenv vimUtils;
  sources = import ../npins { };
  getSrc = name: builtins.getAttr name sources;
  buildPlugin = name: source: {
    name = builtins.replaceStrings [ "." ] [ "-" ] name;
    value = vimUtils.buildVimPlugin {
      pname = builtins.replaceStrings [ "." ] [ "-" ] name;
      version = source.revision;
      src = source;
      doCheck = false;
    };
  };
in
lib.mapAttrs' buildPlugin sources
// {
  # Keep the parser/query versions paired with the pinned nixpkgs grammars.
  nvim-treesitter = pkgs.vimPlugins.nvim-treesitter.overrideAttrs {
    runtimeDeps = [ pkgs.tree-sitter ];
  };
  cmp_luasnip = pkgs.vimPlugins.cmp_luasnip;
  # The pinned minimap predates nvim-treesitter's removal of ts_utils.
  codewindow-nvim = vimUtils.buildVimPlugin {
    pname = "codewindow-nvim";
    version = sources."codewindow.nvim".revision;
    src = sources."codewindow.nvim";
    patches = [ ./patches/codewindow-neovim-treesitter.patch ];
    doCheck = false;
  };

  LuaSnip = vimUtils.buildVimPlugin rec {
    pname = "LuaSnip";
    version = src.revision;
    src = getSrc pname;
    nativeBuildInputs = [ pkgs.gcc ];
    buildPhase = ''
      ${lib.optionalString stdenv.isDarwin "LUA_LDLIBS='-undefined dynamic_lookup -all_load'"}
      JSREGEXP_PATH=deps/jsregexp
      make "INCLUDE_DIR=-I $PWD/deps/lua51_include" LDLIBS="$LUA_LDLIBS" -C $JSREGEXP_PATH
      cp $JSREGEXP_PATH/jsregexp.so lua/luasnip-jsregexp.so
    '';
  };

  vim-sonictemplate =
    let
      root = getSrc "vim-sonictemplate";
    in
    vimUtils.buildVimPlugin {
      pname = "vim-sonictemplate";
      version = root.revision;
      src = pkgs.nix-filter {
        inherit root;
        exclude = [
          "template/java"
          "template/make"
        ];
      };
    };

  telescope-fzf-native-nvim = vimUtils.buildVimPlugin rec {
    pname = "telescope-fzf-native-nvim";
    version = src.revision;
    src = getSrc "telescope-fzf-native.nvim";
    buildPhase = "make";
  };

  actually-doom-nvim =
    let
      doom = stdenv.mkDerivation rec {
        pname = "doom";
        src = getSrc "actually-doom.nvim";
        version = src.revision;
        nativeBuildInputs = [ pkgs.gcc ];
        installPhase = ''
          cd doom
          make OUTDIR=$out
        '';
      };
    in
    vimUtils.buildVimPlugin rec {
      pname = "actually-doom.nvim";
      src = getSrc pname;
      version = src.revision;
      postInstall = ''
        ln -s ${doom} $out/doom/build
      '';
    };

  # Reuse the existing flake lock entries; these names are not v3 dependencies
  # on another configuration's package namespace.
  inherit (inputs'.v2-pterm.packages) pterm pterm-daemon;
  inherit (inputs'.v2-meian.packages) meian;
  inherit (inputs'.v2-track.packages) track track-cli;
}
