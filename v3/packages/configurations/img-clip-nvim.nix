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
    # img-clip.nvim

    ## 概要
    画像をクリップボードなどからマークアップ文書へ埋め込む。

    ## 主な機能
    - 画像の貼り付け、ドラッグ＆ドロップ、URL・ファイル・Base64 に対応する。
    - ファイルタイプ別テンプレートや画像処理コマンドを設定できる。

    ## 使い方
    `:PasteImage` または `require("img-clip").paste_image(opts, input)` を使う。`:ImgClipConfig` で設定、`:ImgClipDebug` でログ、`:checkhealth img-clip` で要件を確認する。

    ## 要件
    Linux は X11 の xclip または Wayland の wl-clipboard、macOS は pngpaste が必要。Windows に追加要件はない。画像処理コマンドを指定する場合はその実行環境も必要。

    ## 出典
    [固定バージョンの README](https://github.com/hakonharnes/img-clip.nvim/blob/99848daf801789dbebe2192b475eb887d375002c/README.md)
  '';

  plugin = sources.img-clip-nvim;
  config = luaConfig (
    # lua
    ''
      require("img-clip").setup({
        default = {
          dir_path = ".",
          extension = "png",
          file_name = "%Y-%m-%d_%H%M%S",
          use_absolute_path = false,
          relative_to_current_file = true,
          template = "$FILE_PATH",
          url_encode_path = false,
          relative_template_path = true,
          use_cursor_in_template = true,
          insert_mode_after_paste = true,
          prompt_for_file_name = false,
          show_dir_path_in_prompt = false,
          max_base64_size = 10,
          embed_image_as_base64 = false,
          process_cmd = "",
          copy_images = false,
          download_images = true,
          drag_and_drop = { enabled = true, insert_mode = false },
        },
        filetypes = {
          markdown = {
            url_encode_path = false,
            template = "![$CURSOR]($FILE_PATH)",
            download_images = false,
          },
          html = { template = '<img src="$FILE_PATH" alt="$CURSOR">' },
        },
      })
    ''
  );
}
