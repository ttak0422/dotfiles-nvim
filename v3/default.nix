{ pkgs, inputs' }:
let
  packages = import ./packages { inherit pkgs inputs'; };
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
