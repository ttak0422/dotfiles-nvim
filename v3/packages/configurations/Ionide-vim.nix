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
  plugin = sources.Ionide-vim;
  doc = ''
    # Ionide-Vim

    ## 概要
    FsAutoComplete を利用して Vim / Neovim に F# 開発支援を追加する。

    ## 主な機能
    - F# の構文強調、補完、診断とコード操作。
    - F# Interactive への式・バッファ送信。

    ## 使い方
    `*.fs`・`*.fsi`・`*.fsx` を開いて利用する。`:FSharpShowLoadedProjects` で読み込み済みプロジェクトを確認し、`:FsiShow`・`:FsiEvalBuffer` で FSI を操作する。

    ## 要件
    Neovim または Vim 8 以降、.NET Core SDK、FsAutoComplete。組み込み LSP は Neovim 0.11.3 以降が必要で、Vim / 旧 Neovim では LanguageClient-neovim を使用する。

    ## 出典
    - [上流 README（固定リビジョン）](https://github.com/ionide/Ionide-vim/blob/30aac182c9652f37b5ce65942e5cc32371595995/README.mkd)
  '';
  preConfig = luaConfig (
    # lua
    ''
      vim.g["fsharp#lsp_recommended_colorscheme"] = 0
      vim.g["fsharp#lsp_codelens"] = 0
    ''
  );
  config = luaConfig (
    # lua
    ''
      vim.lsp.config("ionide", {})
      vim.lsp.enable("ionide")
    ''
  );
  extraPackages = with pkgs; [
    dotnet-sdk_9
    fsautocomplete
  ];
}
