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
  plugin = sources.image-nvim;
  doc = ''
    # image.nvim

    ## 概要
    ターミナルの画像描画機能を使って Neovim 内に画像を表示する。

    ## 主な機能
    - 画像の読み込み・描画・拡大縮小を行う Lua API。
    - Markdown・Neorg などへの任意の組み込み連携。

    ## 使い方
    `require("image").setup()` でバックエンドを選ぶ。API では `require("image").from_file(path)` で画像を作り、`:render()`・`:clear()` で表示を制御する。

    ## 要件
    ImageMagick と対応する描画環境が必要。Kitty バックエンドは Kitty 28.0 以降を推奨し、代替は Überzug++ または Sixel 対応端末。`magick_rock` を選ぶ場合は LuaRocks と magick バインディングも必要。

    ## 出典
    - [上流 README（固定リビジョン）](https://github.com/3rd/image.nvim/blob/da2be65c153ba15a14a342b05591652a6df70d58/README.md)
  '';
  extraPackages = with pkgs; [
    imagemagick
    ghostscript
  ];
  config = luaConfig (
    # lua
    ''
      -- The package is eager; terminal graphics initialization needs a UI.
      local function setup_image()
        if vim.g.neovide then
          return
        end
        require("image").setup({
          backend = "kitty",
          integrations = {
            markdown = {
              enabled = true,
              clear_in_insert_mode = false,
              download_remote_images = true,
              only_render_image_at_cursor = true,
              only_render_image_at_cursor_mode = "popup",
              floating_windows = false,
              filetypes = { "markdown", "vimwiki" },
            },
          },
          max_height = 20,
          max_height_window_percentage = math.huge,
          max_width_window_percentage = math.huge,
          window_overlap_clear_enabled = true,
          window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
        })
      end

      if not vim.g.neovide then
        if #vim.api.nvim_list_uis() > 0 then
          setup_image()
        else
          vim.api.nvim_create_autocmd("UIEnter", { once = true, callback = setup_image })
        end
      end
    ''
  );
}
