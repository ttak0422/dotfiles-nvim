{ sources, ... }:
{
  doc = ''
    # vim-mr

    MRU（使用ファイル）、MRW（保存ファイル）、MRR（リポジトリ）、
    MRD（ディレクトリ）の履歴を起動時から自動記録する。
    Telescope MR から履歴を選択できる。Vimscript の記録・取得 API のみを
    使用するため、Denops / Deno は不要。

    [固定リビジョンの実装](https://github.com/lambdalisue/vim-mr/blob/2602c0bea2066afbc6cc5cc27ea99f2f51c66893/plugin/mr.vim)
  '';
  # Record before the first Telescope invocation, including startup file events.
  plugin = sources.vim-mr;
}
