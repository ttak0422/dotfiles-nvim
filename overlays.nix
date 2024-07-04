inputs: with inputs; [
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
        ));
    }
  )
]
