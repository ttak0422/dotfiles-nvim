inputs: with inputs; [
  nix-filter.overlays.default
  (
    final: prev:
    let
      inherit (builtins)
        filter
        elem
        attrNames
        listToAttrs
        getAttr
        ;
      inherit (prev.lib) optionalString;
      inherit (prev.stdenv) system isDarwin;
      inherit (prev.vimUtils) buildVimPlugin;
      excludeInputs = [
        "self"
        "nixpkgs"
        "nixpkgs-stable"
        "systems"
        "flake-parts"
        "nix-filter"
        "bundler"
        "loaded-nvim"
      ];
      plugins = filter (name: !(elem name excludeInputs)) (attrNames inputs);
      base = {
        version = "overlay";
      };
    in
    {
      pkgs-stable = import nixpkgs-stable { inherit system; };
      vimPlugins =
        prev.vimPlugins
        // (listToAttrs (
          map (name: {
            inherit name;
            value = buildVimPlugin {
              version = "bundled";
              pname = name;
              src = getAttr name inputs;
            };
          }) plugins
        ))
        // {
          telescope-fzf-native-nvim = buildVimPlugin (
            base
            // {
              pname = "telescope-fzf-native-nvim";
              src = inputs.telescope-fzf-native-nvim;
              buildPhase = "make";
            }
          );
          vim-sonictemplate = buildVimPlugin (
            base
            // {
              pname = "vim-sonictemplate";
              src = prev.nix-filter {
                root = inputs.vim-sonictemplate;
                exclude = [
                  "template/java"
                  "template/make"
                ];
              };
            }
          );
          LuaSnip = buildVimPlugin (
            base
            // {
              pname = "LuaSnip";
              src = inputs.LuaSnip;
              nativeBuildInputs = [ prev.gcc ];
              buildPhase = ''
                ${optionalString isDarwin "LUA_LDLIBS='-undefined dynamic_lookup -all_load'"}
                JSREGEXP_PATH=deps/jsregexp
                make "INCLUDE_DIR=-I $PWD/deps/lua51_include" LDLIBS="$LUA_LDLIBS" -C $JSREGEXP_PATH
                cp $JSREGEXP_PATH/jsregexp.so lua/luasnip-jsregexp.so
              '';
            }
          );
        };
    }
  )
]
