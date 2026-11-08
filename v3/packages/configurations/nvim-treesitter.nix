{
  pkgs,
  lib,
  sources,
  definitions,
  luaConfig,
  luaCheck,
  inputs',
}:
with sources;
{
  doc = ''
    # nvim-treesitter

    ## 概要
    Tree-sitter パーサーの管理と、Neovim の構文機能に使う query を提供するプラグイン。

    ## 主な機能
    - パーサーのインストール・更新・削除。
    - ハイライト・fold などの言語別 query を提供。

    ## 使い方
    README は `require("nvim-treesitter").setup(...)` を案内し、ハイライトは別途 `vim.treesitter.start()` で有効にする。この定義は Nix でパーサーを用意するため、README の `:TSUpdate` を通常のパーサー更新手段としては扱わない。

    ## 要件
    固定 README は Neovim 0.12.0 以上、tar、curl、tree-sitter-cli 0.26.1 以上、C コンパイラーを挙げる。後者は README のパーサー取得・ビルド手順用。遅延読込は非対応。

    ## 出典
    [固定リビジョンの README](https://github.com/nvim-treesitter/nvim-treesitter/blob/29212d826054bb2948fa9d3a99eca9bf6a050eb2/README.md)
  '';
  plugin = sources.nvim-treesitter;
  preConfig = luaConfig {
    code = ''
      assert(loadfile("${../support/markdown-fences/setup.lua}"))(args)
    '';
    args = {
      injections = builtins.readFile ../support/markdown-fences/injections.scm;
      highlights = builtins.readFile ../support/markdown-fences/highlights.scm;
    };
  };
  config = luaConfig (
    let
      inherit (pkgs.tree-sitter) buildGrammar version;

      dap-repl = buildGrammar {
        inherit version;
        language = "dap_repl";
        src = nvim-dap-repl-highlights;
      };

      inherit (pkgs.vimPlugins.nvim-treesitter) allGrammars;

      grammarPlugins = map pkgs.neovimUtils.grammarToPlugin allGrammars;

      queryPlugins = lib.pipe allGrammars [
        (map (g: g.passthru.associatedQuery or null))
        (lib.filter (q: q != null))
      ];

      parserDrv = pkgs.stdenv.mkDerivation {
        name = "treesitter-custom-grammars";
        buildCommand =
          let
            allPlugins = grammarPlugins ++ queryPlugins;
          in
          ''
            deps="${lib.strings.concatStringsSep " " allPlugins}"
            mkdir -p $out/parser
            mkdir -p $out/queries

            if [ -d "${nvim-treesitter}/runtime/queries" ]; then
              find -L "${nvim-treesitter}/runtime/queries" -type f -name '*.scm' -print0 \
                | while IFS= read -r -d $'\0' f; do
                    rel="''${f#"${nvim-treesitter}/runtime/queries/"}"
                    mkdir -p "$out/queries/$(dirname "$rel")"
                    ln -sf "$f" "$out/queries/$rel"
                  done
            fi

            for d in $deps; do
              # parser/<lang>.so
              if [ -d "$d/parser" ]; then
                find "$d/parser" -maxdepth 1 -name '*.so' -print0 \
                  | while IFS= read -r -d $'\0' f; do
                      ln -sf "$f" "$out/parser/$(basename "$f")"
                    done
              fi
              # queries/<lang>/*.scm
              if [ -d "$d/queries" ]; then
                find -L "$d/queries" -type f -name '*.scm' -print0 \
                  | while IFS= read -r -d $'\0' f; do
                      rel="''${f#"$d/queries/"}"
                      mkdir -p "$out/queries/$(dirname "$rel")"
                      ln -sf "$f" "$out/queries/$rel"
                    done
              fi
            done

            # WIP: custom grammars
            mkdir -p $out/queries/dap_repl
            ln -sf ${dap-repl}/parser $out/parser/dap_repl.so
            ln -sf ${dap-repl}/queries/dap_repl/highlights.scm $out/queries/dap_repl/highlights.scm
          '';
      };
    in
    {
      code = # lua
        ''
          require("nvim-treesitter").setup({ install_dir = args.install_dir })
          vim.opt.foldmethod = "expr"
          vim.opt.foldexpr = "&filetype ==# 'markdown' ? 0 : v:lua.vim.treesitter.foldexpr()"
          vim.api.nvim_create_autocmd("FileType", {
            callback = function()
              pcall(vim.treesitter.start)
              if vim.bo.filetype == "markdown" then
                if vim.bo.indentexpr == "v:lua.require'nvim-treesitter'.indentexpr()" then
                  vim.bo.indentexpr = ""
                end
              elseif vim.bo.indentexpr == "" then
                vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
              end
            end,
          })
        '';
      args.install_dir = toString parserDrv;
    }
  );
  tests.markdown-fences = luaCheck {
    name = "markdown-fences";
    ui = true;
    script = builtins.readFile ../support/markdown-fences/check.lua;
  };
}
