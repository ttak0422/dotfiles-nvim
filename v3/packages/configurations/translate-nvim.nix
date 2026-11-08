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
  plugin = sources.translate-nvim;
  doc = ''
    # translate.nvim

    ## 概要
    外部の翻訳コマンドや API を使い、選択テキストを翻訳する。

    ## 主な機能
    - Google Translate・translate-shell・DeepL などの翻訳手段。
    - フロート・分割・挿入・置換・レジスターなどの出力先。

    ## 使い方
    `:[range]Translate {target-lang}` で範囲を翻訳する。範囲未指定なら現在行が対象で、`-command=`・`-output=` で処理方法を選べる。

    ## 要件
    Neovim 0.8 以降。既定の Google Translate は curl、translate-shell は trans、DeepL は対応 API キーと curl が必要。外部サービスへ翻訳対象を送信する。

    ## 出典
    - [上流 README（固定リビジョン）](https://github.com/uga-rosa/translate.nvim/blob/1a841e56407ba02e919ed9af573dbe531404aebb/README.md)
  '';
  extraPackages = [ pkgs.curl ];
  config = luaConfig (
    # lua
    ''
      require("translate").setup({
        preset = {
          output = {
            floating = { zindex = 150 },
            split = {
              position = "bottom",
              min_size = 5,
              max_size = 0.5,
              name = "translate://output",
              filetype = "translate",
              append = false,
            },
          },
        },
        default = { output = "split" },
      })
    ''
  );
}
