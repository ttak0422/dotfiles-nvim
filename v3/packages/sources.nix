{ pkgs, inputs' }:
let
  inherit (pkgs) lib stdenv vimUtils;
  sources = import ../../npins-sources.nix ../npins;
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
  goda-skk = import ./skk/package.nix { inherit pkgs sources; };

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

  # Native packages use the pinned v3 inputs.
  inherit (inputs'.v3-pterm.packages) pterm pterm-daemon;
  inherit (inputs'.v3-meian.packages) meian;
  inherit (inputs'.v3-track.packages) track track-cli;
}
