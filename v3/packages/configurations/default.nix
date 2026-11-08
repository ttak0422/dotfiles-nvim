{
  pkgs,
  sources,
  inputs',
}:
let
  lib = pkgs.lib;
  emptyPlugin = name: pkgs.runCommand ("v3-" + name) { } "mkdir -p $out";
  # Preserve the lexical args contract of owned configs, not v2 loader behavior.
  luaConfig =
    value:
    if builtins.isString value then
      value
    else if (value.language or "lua") == "vim" then
      "vim.cmd(" + lib.generators.toLua { } value.code + ")"
    else
      "local args = " + lib.generators.toLua { } (value.args or { }) + "\n" + value.code;
  load =
    path:
    import path {
      inherit
        pkgs
        lib
        sources
        definitions
        luaConfig
        emptyPlugin
        inputs'
        ;
    };
  definitions = {
    plenary = load ./plenary.nix;
    bg = load ./bg.nix;
    meian = load ./meian.nix;
    nui = load ./nui.nix;
    asterisk = load ./asterisk.nix;
    config-local = load ./config-local.nix;
    snacks = load ./snacks.nix;
    cmp = load ./cmp.nix;
    luasnip = load ./luasnip.nix;
    treesitter = load ./treesitter.nix;
    scope = load ./scope.nix;
    lastplace = load ./lastplace.nix;
    lsp = load ./lsp.nix;
    none-ls = load ./none-ls.nix;
    gitsigns = load ./gitsigns.nix;
    hud = load ./hud.nix;
    rustaceanvim = load ./rustaceanvim.nix;
    rustowl = load ./rustowl.nix;
    jsonl = load ./jsonl.nix;
    cmdline = load ./cmdline.nix;
    sorairo = load ./sorairo.nix;
    morimo2 = load ./morimo2.nix;
    kanagawa = load ./kanagawa.nix;
    nvim-grey = load ./nvim-grey.nix;
    zen = load ./zen.nix;
    nio = load ./nio.nix;
    worktab = load ./worktab.nix;
    devicons = load ./devicons.nix;
    project = load ./project.nix;
    md-render = load ./md-render.nix;
    mcphub = load ./mcphub.nix;
    lspPlugins = load ./lspPlugins.nix;
    dap = load ./dap.nix;
    dap-ui = load ./dap-ui.nix;
    gopher = load ./gopher.nix;
    crates = load ./crates.nix;
    hlslens = load ./hlslens.nix;
    bufferPlugins = load ./bufferPlugins.nix;
    preBufferPlugins = load ./preBufferPlugins.nix;
    inputPlugins = load ./inputPlugins.nix;
    editPlugins = load ./editPlugins.nix;
    togglePlugins = load ./togglePlugins.nix;
    toggleterm = load ./toggleterm.nix;
    telescope = load ./telescope.nix;
    trouble = load ./trouble.nix;
    obsidian = load ./obsidian.nix;
    track = load ./track.nix;
    image = load ./image.nix;
    img-clip = load ./img-clip.nix;
    mdpaste = load ./mdpaste.nix;
    quickfixPlugins = load ./quickfixPlugins.nix;
    modulePlugins = load ./modulePlugins.nix;
    commandPlugins = load ./commandPlugins.nix;
    cmdlinePlugins = load ./cmdlinePlugins.nix;
    vimLeavePrePlugins = load ./vimLeavePrePlugins.nix;
    windowPlugins = load ./windowPlugins.nix;
    conjure = load ./conjure.nix;
    filetypePlugins = load ./filetypePlugins.nix;
    dirChangedPrePlugins = load ./dirChangedPrePlugins.nix;
    termOpenPlugins = load ./termOpenPlugins.nix;
  };
in
{
  inherit definitions;
  plugins = builtins.attrValues definitions;
}
