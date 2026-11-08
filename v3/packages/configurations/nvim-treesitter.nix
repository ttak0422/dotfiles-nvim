{
  pkgs,
  lib,
  sources,
  definitions,
  luaConfig,
  inputs',
}:
with sources;
{
  plugin = sources.nvim-treesitter;
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
          vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
          vim.api.nvim_create_autocmd("FileType", {
            callback = function()
              pcall(vim.treesitter.start)
              if vim.bo.indentexpr == "" then
                vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
              end
            end,
          })
        '';
      args.install_dir = toString parserDrv;
    }
  );
}
