{ sources }:
{
  plugin = sources.goda-vim;
  doc = ''
    # goda.vim

    ## 概要
    Vim/NeovimとGoプログラム間の通信を担うプラグインフレームワークです。
    Denoには依存せず、同じバイナリで両エディタに対応します。APIは初期段階です。

    ## 主な機能
    - エディタとGoプラグインのメッセージ交換、プラグインからのエディタ呼び出しに対応します。
    - `goda#register()`で登録したバイナリを、最初のrequestで起動・再起動できます。
    - JSONL transportでエディタ外から通信を試せます。エディタへのcallbackはこの経路では使えません。

    ## 使い方
    READMEはGoの`host.Main`と`Handler`でプラグインを実装する例を示しています。
    エディタ側では`goda#start()`と`goda#request()`で呼び出し、`goda#log()`で診断します。
    goda.vim自体には`plugin/`スクリプトがなく、最初の`goda#...()`呼び出しで読み込まれます。

    ## 要件
    ビルド用Go 1.26以上、Neovim 0.11以上、または`+job +channel`付きVim 9.1以上が必要です。
    READMEは同名の別ツールとの衝突を避けるため、プラグインバイナリを`goda`と命名しないよう案内しています。

    ## 出典
    [goda.vim README（v0.7.2の固定revision）](https://github.com/Shougo/goda.vim/blob/8399891df7fd77eee0473003201f9960dfbd8ebb/README.md)
  '';
}
