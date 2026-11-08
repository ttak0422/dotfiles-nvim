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
  plugin = sources.nvim-web-devicons;
  doc = ''
    # Nvim-web-devicons

    ## 概要
    ファイル名・拡張子などに対応するアイコンと色を提供する Lua ライブラリ。

    ## 主な機能
    - 明暗テーマに応じたアイコン色。
    - ファイル名・拡張子・filetype の取得 API と個別上書き。

    ## 使い方
    `require("nvim-web-devicons").setup()` で設定し、`get_icon(filename, extension, options)` でアイコンとハイライト名を取得する。`:NvimWebDeviconsHiTest` で一覧を確認できる。

    ## 要件
    Neovim 0.7.0 以降と対応するパッチ済みフォント。README は Nerd Fonts 2.3 以降を要求する。

    ## 出典
    - [上流 README（固定リビジョン）](https://github.com/nvim-tree/nvim-web-devicons/blob/5b9067899ee6a2538891573500e8fd6ff008440f/README.md)
  '';
  config = luaConfig (
    # lua
    ''
      require("nvim-web-devicons").setup({
        color_icons = false,
        override_by_filename = {},
        override_by_extension = {
          norg = { icon = "", name = "Neorg" },
        },
      })
    ''
  );
  tests.devicons-overrides = luaCheck {
    name = "devicons-overrides";
    script = ''
      local icons = require("nvim-web-devicons")
      local icon, highlight = icons.get_icon("notes.norg", "norg", { strict = true })
      assert(icon == "", "norg must use the configured Neorg icon")
      assert(icons.get_icons_by_extension().norg.name == "Neorg", "norg override metadata must survive setup")
      local lua_icon, lua_highlight = icons.get_icon("init.lua", "lua", { strict = true })
      local fallback, fallback_highlight = icons.get_icon("unknown.__v3_test__", "__v3_test__", { default = true })
      assert(type(lua_icon) == "string" and #lua_icon > 0, "standard extension icons must remain available")
      assert(type(fallback) == "string" and #fallback > 0, "unknown extensions must support the fallback icon")
      assert(highlight == fallback_highlight and lua_highlight == fallback_highlight,
        "color_icons=false must return one shared highlight for custom, standard and fallback icons")
      assert(icons.get_icon("unknown.__v3_test__", "__v3_test__", { strict = true, default = false }) == nil,
        "unknown extensions must stay absent when fallback is disabled")
    '';
  };
}
