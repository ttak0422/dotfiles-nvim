{
  sources,
  luaConfig,
  luaCheck,
  environment,
}:
{
  doc = ''
    # win-box.nvim

    Neovim 0.12 以降の分割ウィンドウ用。境界表示、選択、リサイズ、
    移動・交換、画面サイズ変更時の分割比維持をまとめる。
    キーマップはプラグインではなく dotfiles のウィンドウ設定が管理する。
  '';
  plugin = sources.win-box-nvim;
  config = luaConfig ''
    require("win_box").setup({
      boundary = true,
      keep_ratio = true,
      picker = { style = "large" },
      ignore_filetypes = { "TelescopePrompt" },
    })
  '';
  tests.win-box-layout = luaCheck {
    name = "win-box-layout";
    ui = true;
    preInit = ''
      vim.g.neovide = ${if environment == "neovide" then "true" else "nil"}
      vim.env.XDG_RUNTIME_DIR = vim.fn.tempname()
      vim.fn.mkdir(vim.env.XDG_RUNTIME_DIR, "p", 448)
    '';
    script = builtins.readFile ../checks/win-box-layout.lua;
  };
}
