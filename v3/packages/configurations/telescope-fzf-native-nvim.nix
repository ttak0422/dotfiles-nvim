{
  pkgs,
  lib,
  sources,
  definitions,
  luaConfig,
  inputs',
}:
{
  doc = ''
    # telescope-fzf-native.nvim

    ## 概要
    fzf の照合アルゴリズムを C で実装した Telescope 用ソーター。

    ## 主な機能
    - あいまい一致、完全一致、前方・後方一致、否定、OR に対応する。
    - 一致スコアと位置を計算し、Telescope のソートを置き換える。

    ## 使い方
    Telescope の設定後に `require("telescope").load_extension("fzf")` を呼ぶ。`extensions.fzf` で `fuzzy`、`case_mode`、既存ソーターの置換を設定する。

    ## 要件
    Telescope との連携を前提とする。ネイティブ部分のビルドには make と GCC / Clang、または CMake を使用する。Windows の CMake 構成には Microsoft C++ Build Tools が必要。

    ## 出典
    [固定バージョンの README](https://github.com/nvim-telescope/telescope-fzf-native.nvim/blob/b25b749b9db64d375d782094e2b9dce53ad53a40/README.md)
  '';

  plugin = sources.telescope-fzf-native-nvim;
}
