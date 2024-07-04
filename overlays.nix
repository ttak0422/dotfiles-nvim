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
      inherit (prev.stdenv) system;
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
          telescope-fzf-native-nvim = buildVimPlugin {
            pname = "telescope-fzf-native-nvim";
            version = "overlay";
            src = inputs.telescope-fzf-native-nvim;
            buildPhase = "make";
          };
          vim-sonictemplate = buildVimPlugin {
            pname = "vim-sonictemplate";
            version = "overlay";
            src = prev.nix-filter {
              root = inputs.vim-sonictemplate;
              exclude = [
                "template/java"
                "template/make"
              ];
            };
          };
        };
    }
  )
]
