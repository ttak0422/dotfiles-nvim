{
  pkgs,
  inputs',
  environment,
}:
let
  luaCheck = import ../packages/plugin-check.nix;
  packages = import ../packages { inherit pkgs inputs' environment; };
in
with packages;
{
  startupConfig = ''
    vim.o.termguicolors = true
    -- Fyler clears netrw's group even when netrw is disabled before startup.
    vim.api.nvim_create_augroup("FileExplorer", { clear = false })
    vim.g.python3_host_prog = "${pkgs.python3.withPackages (ps: [ ps.pynvim ])}/bin/python3"
    ${core.startupConfig}
  '';
  extraPackages = with pkgs; [
    jq
    git
  ]
  ++ configurations.extraPackages;
  plugins = configurations.plugins ++ [
    (
      core.definition
      // {
        test = luaCheck {
          name = "environment-${environment}";
          preInit = if environment == "neovide" then "vim.g.neovide = true" else "";
          script = ''
            local gui = ${if environment == "neovide" then "true" else "false"}
            assert(vim.env.NVIM_APPNAME == "nvim-v3-${environment}")
            local image = vim.api.nvim_get_runtime_file("lua/image/init.lua", true)
            assert((#image == 0) == gui, "terminal image plugin must be absent from Neovide")
            local bg = vim.api.nvim_get_runtime_file("plugin/bg.lua", true)
            assert((#bg == 0) == gui, "terminal color plugin must be absent from Neovide")
            assert((vim.fn.exists(":ToggleNeovideBlur") == 2) == gui)
            if gui then
              assert(vim.g.neovide_padding_top == 10)
              assert(vim.o.guifont == "PlemolJP Console NF:h15")
              assert(vim.fn.maparg("<D-v>", "i") ~= "")
            else
              assert(vim.g.neovide_padding_top == nil)
            end
          '';
        };
        dependPlugins = with configurations.definitions; [
          snacks-nvim
          sorairo
          nvim-config-local
        ];
        preConfig = configurations.editorPreConfig;
        config = pkgs.lib.concatStringsSep "\n" [
          configurations.editorConfig
          core.definition.config
        ];
      }
    )
  ];
}
