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
  doc = ''
    # sfcc.nvim

    ## 概要
    Salesforce B2C Commerce Cloud のカートリッジ内パスへ移動する。

    ## 主な機能
    - `*/`、`~/`、相対パス、モジュール名をカートリッジ順序に従って解決する。
    - `module.superModule` では次のカートリッジにある同じファイルへ移動する。

    ## 使い方
    `require("sfcc").gf()` をキーに割り当てる。この定義は JavaScript の `gf` に設定する。`:SfccReset` で探索キャッシュを消去し、`:checkhealth sfcc` で検出内容を確認する。

    ## 要件
    カートリッジ順序は `dw.json` の `cartridgesPath` を参照する。対象外のプロジェクトでは標準 `gf` へ戻る。最低 Neovim バージョンは README に未記載。

    ## 出典
    [固定バージョンの README](https://github.com/ttak0422/sfcc.nvim/blob/a78991511dc4b6de7bfca59d1497c9bc9fda4b8f/README.md)
  '';

  plugin = sources.sfcc-nvim;
  config = luaConfig (''
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'javascript',
      callback = function(event)
        vim.keymap.set('n', 'gf', function() require('sfcc').gf() end,
          { buffer = event.buf, desc = 'SFCC cartridge gf' })
      end,
    })
  '');
}
