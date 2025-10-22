{ inputs }:
final: prev:
let

  inherit (builtins) getAttr;
  inherit (final)
    stdenv
    lib
    vimUtils
    rustPlatform
    ;
  ext = stdenv.hostPlatform.extensions.sharedLibrary;
  getSrc = name: getAttr name (import ./npins);
in
rec {
  blink-cmp = vimUtils.buildVimPlugin rec {
    pname = "blink.cmp";
    version = src.revision;
    src = getSrc pname;
    preInstall =
      let
        blink-fuzzy-lib = rustPlatform.buildRustPackage {
          inherit (blink-cmp) src version;
          pname = "blink-fuzzy-lib";
          cargoHash = "sha256-zWZHT+Y8ENN/nFEtJnkEUHXRuU6FUQ/ITHo+V4zJ6f8=";
          nativeBuildInputs = with final; [ gitMinimal ];
          env.RUSTC_BOOTSTRAP = true;
        };
      in
      # bash
      ''
        mkdir -p $out/target/release
        ln -s ${blink-fuzzy-lib}/lib/libblink_cmp_fuzzy${ext} $out/target/release/libblink_cmp_fuzzy${ext}
      '';
    doCheck = false;
  };
  avante-nvim = vimUtils.buildVimPlugin rec {
    pname = "avante.nvim";
    version = src.revision;
    src = getSrc pname;
    preInstall =
      let
        avante-nvim-lib = rustPlatform.buildRustPackage {
          inherit (avante-nvim) src version;
          pname = "avante-nvim-lib";
          cargoHash = "sha256-pTWCT2s820mjnfTscFnoSKC37RE7DAPKxP71QuM+JXQ=";
          buildFeatures = [ "luajit" ];
          doCheck = false;
        };
      in
      # bash
      ''
        mkdir -p $out/build
        ln -s ${avante-nvim-lib}/lib/libavante_html2md${ext}    $out/build/avante_html2md${ext}
        ln -s ${avante-nvim-lib}/lib/libavante_repo_map${ext}   $out/build/avante_repo_map${ext}
        ln -s ${avante-nvim-lib}/lib/libavante_templates${ext}  $out/build/avante_templates${ext}
        ln -s ${avante-nvim-lib}/lib/libavante_tokenizers${ext} $out/build/avante_tokenizers${ext}
      '';
    doCheck = false;
  };
  LuaSnip = vimUtils.buildVimPlugin rec {
    pname = "LuaSnip";
    version = src.revision;
    src = getSrc pname;
    nativeBuildInputs = with final; [ gcc ];
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
      src = prev.nix-filter {
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
  gin-vim = vimUtils.buildVimPlugin rec {
    pname = "gin.vim";
    src = getSrc "gin.vim";
    version = src.revision;
    # dontPatchShebangs = true;
    # postInstall = ''
    #   substituteInPlace \
    #   $out/denops/gin/proxy/editor.ts \
    #   $out/denops/gin/proxy/askpass.ts \
    #   --replace "/usr/bin/env -S deno" "${prev.deno}/bin/deno"
    # '';
  };
  inherit (inputs.v2-fff-nvim.packages.${stdenv.system}) fff-nvim;
}
