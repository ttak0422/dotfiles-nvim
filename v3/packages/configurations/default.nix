{
  pkgs,
  sources,
  inputs',
}:
let
  lib = pkgs.lib;
  # Preserve the lexical args contract without a separate loader or marker plugin.
  luaConfig =
    value:
    if builtins.isString value then
      value
    else if (value.language or "lua") == "vim" then
      "vim.cmd(" + lib.generators.toLua { } value.code + ")"
    else
      "local args = " + lib.generators.toLua { } (value.args or { }) + "\n" + value.code;
  luaCheck = import ../plugin-check.nix;
  load =
    path:
    let
      module = import path;
      args = {
        inherit
          pkgs
          lib
          sources
          definitions
          luaConfig
          luaCheck
          inputs'
          ;
      };
    in
    module (builtins.intersectAttrs (builtins.functionArgs module) args);

  # Definitions own actual plugins or explicit groups with shared configuration.
  pluginDefinitions = {
    Comment-nvim = load ./Comment-nvim.nix;
    Ionide-vim = load ./Ionide-vim.nix;
    LuaSnip = load ./LuaSnip.nix;
    NeoZoom-lua = load ./NeoZoom-lua.nix;
    aerial-nvim = load ./aerial-nvim.nix;
    atone-nvim = load ./atone-nvim.nix;
    auto-save-nvim = load ./auto-save-nvim.nix;
    better-escape-nvim = load ./better-escape-nvim.nix;
    bg-nvim = load ./bg-nvim.nix;
    blame-nvim = load ./blame-nvim.nix;
    budoux-lua = load ./budoux-lua.nix;
    capture-vim = load ./capture-vim.nix;
    claudecode-nvim = load ./claudecode-nvim.nix;
    colorful-winsep-nvim = load ./colorful-winsep-nvim.nix;
    conjure = load ./conjure.nix;
    crates-nvim = load ./crates-nvim.nix;
    csvview-nvim = load ./csvview-nvim.nix;
    detour-nvim = load ./detour-nvim.nix;
    dial-nvim = load ./dial-nvim.nix;
    diffview-nvim = load ./diffview-nvim.nix;
    direnv-nvim = load ./direnv-nvim.nix;
    dmacro-vim = load ./dmacro-vim.nix;
    draw-line-nvim = load ./draw-line-nvim.nix;
    fidget-nvim = load ./fidget-nvim.nix;
    fix-auto-scroll-nvim = load ./fix-auto-scroll-nvim.nix;
    foldnav-nvim = load ./foldnav-nvim.nix;
    fyler-nvim = load ./fyler-nvim.nix;
    garbage-day-nvim = load ./garbage-day-nvim.nix;
    git-conflict-nvim = load ./git-conflict-nvim.nix;
    gitsigns-nvim = load ./gitsigns-nvim.nix;
    glance-nvim = load ./glance-nvim.nix;
    go-impl-nvim = load ./go-impl-nvim.nix;
    goda-vim = load ./goda-vim.nix;
    goda-skk-vim = load ./goda-skk-vim.nix;
    gopher-nvim = load ./gopher-nvim.nix;
    goplements-nvim = load ./goplements-nvim.nix;
    goto-preview = load ./goto-preview.nix;
    graph_view_toml_parser = load ./graph_view_toml_parser.nix;
    graph_view_yaml_parser = load ./graph_view_yaml_parser.nix;
    guess-indent-nvim = load ./guess-indent-nvim.nix;
    harpoon = load ./harpoon.nix;
    helpview-nvim = load ./helpview-nvim.nix;
    history-ignore-nvim = load ./history-ignore-nvim.nix;
    hlchunk-nvim = load ./hlchunk-nvim.nix;
    hud-nvim = load ./hud-nvim.nix;
    hydra-nvim = load ./hydra-nvim.nix;
    image-nvim = load ./image-nvim.nix;
    img-clip-nvim = load ./img-clip-nvim.nix;
    inc-rename-nvim = load ./inc-rename-nvim.nix;
    kanagawa-nvim = load ./kanagawa-nvim.nix;
    keep-split-ratio-nvim = load ./keep-split-ratio-nvim.nix;
    koe-nvim = load ./koe-nvim.nix;
    komado-nvim = load ./komado-nvim.nix;
    kotlin-nvim = load ./kotlin-nvim.nix;
    leap-nvim = load ./leap-nvim.nix;
    lensline-nvim = load ./lensline-nvim.nix;
    logrotate-nvim = load ./logrotate-nvim.nix;
    lookup-nvim = load ./lookup-nvim.nix;
    lspkind-nvim = load ./lspkind-nvim.nix;
    lush-nvim = load ./lush-nvim.nix;
    markdown-preview-nvim = load ./markdown-preview-nvim.nix;
    marks-nvim = load ./marks-nvim.nix;
    mcphub-nvim = load ./mcphub-nvim.nix;
    md-render-nvim = load ./md-render-nvim.nix;
    mdpaste-nvim = load ./mdpaste-nvim.nix;
    meian = load ./meian.nix;
    menu = load ./menu.nix;
    minty = load ./minty.nix;
    mkdir-nvim = load ./mkdir-nvim.nix;
    morimo2 = load ./morimo2.nix;
    nap-nvim = load ./nap-nvim.nix;
    neogen = load ./neogen.nix;
    nfnl = load ./nfnl.nix;
    nginx-vim = load ./nginx-vim.nix;
    no-neck-pain-nvim = load ./no-neck-pain-nvim.nix;
    none-ls-nvim = load ./none-ls-nvim.nix;
    nui-nvim = load ./nui-nvim.nix;
    nvim-aibo = load ./nvim-aibo.nix;
    nvim-autopairs = load ./nvim-autopairs.nix;
    nvim-bqf = load ./nvim-bqf.nix;
    nvim-cmp = load ./nvim-cmp.nix;
    nvim-colorizer-lua = load ./nvim-colorizer-lua.nix;
    nvim-config-local = load ./nvim-config-local.nix;
    nvim-dap-repl-highlights = load ./nvim-dap-repl-highlights.nix;
    nvim-dap-ui = load ./nvim-dap-ui.nix;
    nvim-dap-virtual-text = load ./nvim-dap-virtual-text.nix;
    nvim-dap = load ./nvim-dap.nix;
    nvim-dd = load ./nvim-dd.nix;
    nvim-fundo = load ./nvim-fundo.nix;
    nvim-grey = load ./nvim-grey.nix;
    nvim-hlslens = load ./nvim-hlslens.nix;
    nvim-jdtls = load ./nvim-jdtls.nix;
    nvim-lspconfig = load ./nvim-lspconfig.nix;
    nvim-nio = load ./nvim-nio.nix;
    nvim-notify = load ./nvim-notify.nix;
    nvim-scrollbar = load ./nvim-scrollbar.nix;
    nvim-spectre = load ./nvim-spectre.nix;
    nvim-surround = load ./nvim-surround.nix;
    nvim-treesitter-textobjects = load ./nvim-treesitter-textobjects.nix;
    nvim-treesitter = load ./nvim-treesitter.nix;
    nvim-ts-autotag = load ./nvim-ts-autotag.nix;
    nvim-ts-context-commentstring = load ./nvim-ts-context-commentstring.nix;
    nvim-ufo = load ./nvim-ufo.nix;
    nvim-web-devicons = load ./nvim-web-devicons.nix;
    nvim-window = load ./nvim-window.nix;
    nvim_context_vt = load ./nvim_context_vt.nix;
    obsidian-nvim = load ./obsidian-nvim.nix;
    oil-nvim = load ./oil-nvim.nix;
    open-nvim = load ./open-nvim.nix;
    other-nvim = load ./other-nvim.nix;
    plenary-nvim = load ./plenary-nvim.nix;
    project-nvim = load ./project-nvim.nix;
    promise-async = load ./promise-async.nix;
    pterm = load ./pterm.nix;
    qf-nvim = load ./qf-nvim.nix;
    replua-nvim = load ./replua-nvim.nix;
    rustaceanvim = load ./rustaceanvim.nix;
    rustowl = load ./rustowl.nix;
    scope-nvim = load ./scope-nvim.nix;
    sfcc-nvim = load ./sfcc-nvim.nix;
    showkeys = load ./showkeys.nix;
    smart-splits-nvim = load ./smart-splits-nvim.nix;
    snacks-nvim = load ./snacks-nvim.nix;
    sorairo = load ./sorairo.nix;
    stickybuf-nvim = load ./stickybuf-nvim.nix;
    switch-vim = load ./switch-vim.nix;
    tabout-nvim = load ./tabout-nvim.nix;
    telescope-nvim = load ./telescope-nvim.nix;
    term-gf-nvim = load ./term-gf-nvim.nix;
    timerly = load ./timerly.nix;
    tiny-cmdline-nvim = load ./tiny-cmdline-nvim.nix;
    tiny-code-action-nvim = load ./tiny-code-action-nvim.nix;
    tiny-glimmer-nvim = load ./tiny-glimmer-nvim.nix;
    tiny-inline-diagnostic-nvim = load ./tiny-inline-diagnostic-nvim.nix;
    todo-comments-nvim = load ./todo-comments-nvim.nix;
    toggler-nvim = load ./toggler-nvim.nix;
    toggleterm-nvim = load ./toggleterm-nvim.nix;
    trace-pr-nvim = load ./trace-pr-nvim.nix;
    track = load ./track.nix;
    translate-nvim = load ./translate-nvim.nix;
    treesj = load ./treesj.nix;
    trim-nvim = load ./trim-nvim.nix;
    trouble-nvim = load ./trouble-nvim.nix;
    ts-error-translator-nvim = load ./ts-error-translator-nvim.nix;
    uv-nvim = load ./uv-nvim.nix;
    videre-nvim = load ./videre-nvim.nix;
    vim-asterisk = load ./vim-asterisk.nix;
    vim-bufsurf = load ./vim-bufsurf.nix;
    vim-gf-improved = load ./vim-gf-improved.nix;
    vim-jsonl = load ./vim-jsonl.nix;
    vim-lastplace = load ./vim-lastplace.nix;
    vim-matchup = load ./vim-matchup.nix;
    vim-nix = load ./vim-nix.nix;
    vim-qfreplace = load ./vim-qfreplace.nix;
    vim-repeat = load ./vim-repeat.nix;
    vim-mr = load ./vim-mr.nix;
    vim-sonictemplate = load ./vim-sonictemplate.nix;
    vim-startuptime = load ./vim-startuptime.nix;
    vimdoc-ja = load ./vimdoc-ja.nix;
    visual-whitespace-nvim = load ./visual-whitespace-nvim.nix;
    volt = load ./volt.nix;
    which-key-nvim = load ./which-key-nvim.nix;
    winresizer = load ./winresizer.nix;
    winshift-nvim = load ./winshift-nvim.nix;
    worktab-nvim = load ./worktab-nvim.nix;
    zen-nvim = load ./zen-nvim.nix;
  };

  # Consumers reference real member packages, never another occurrence of the
  # group. Detailed singleton definitions below own the sole group dependency.
  memberDefinitions = {
    nvim-cmp = {
      plugin = sources.nvim-cmp;
    };
    cmp-nvim-lsp = {
      plugin = sources.cmp-nvim-lsp;
      dependPlugins = [ memberDefinitions.nvim-cmp ];
    };
    telescope-nvim = {
      lazy = true;
      plugin = sources.telescope-nvim;
    };
    telescope-live-grep-args-nvim = {
      lazy = true;
      plugin = sources.telescope-live-grep-args-nvim;
      dependPlugins = [ memberDefinitions.telescope-nvim ];
    };
  };
  # Singleton dependencies retain their configuration without registering tests
  # again. A packages group has occurrence identity, so it must not be reused here.
  definitions =
    lib.mapAttrs (
      _: definition:
      builtins.removeAttrs definition [
        "test"
        "tests"
      ]
    ) pluginDefinitions
    // memberDefinitions;

  # A bare engine dependency resolves to this singleton. Its one group
  # dependency completes shared setup before any consumer can use the engine.
  # The group owns physical members; membership is not a singleton dependency,
  # so there is no cycle and divine loads each member's scripts only once.
  groupDefinitions = lib.genAttrs [ "nvim-cmp" "telescope-nvim" ] (name: {
    plugin = sources.${name};
    lazy = pluginDefinitions.${name}.lazy or false;
    dependPlugins = [ pluginDefinitions.${name} ];
  });

  # User-owned editor features are core configuration, not synthetic plugins.
  editorDefinitions = {
    buffer = load ./editor-buffer.nix;
    cmdline = load ./editor-cmdline.nix;
    editing = load ./editor-editing.nix;
    gitu = load ./editor-gitu.nix;
    options = load ./editor-options.nix;
    terminal = load ./editor-terminal.nix;
    windows = load ./editor-windows.nix;
  };
  editorValues = builtins.attrValues editorDefinitions;
  scoped = code: "do\n" + code + "\nend";
  editorCode =
    field:
    lib.concatMapStringsSep "\n" (
      value: lib.optionalString (value ? ${field}) (scoped value.${field})
    ) editorValues;
in
{
  inherit definitions pluginDefinitions editorDefinitions;
  plugins = builtins.attrValues (pluginDefinitions // groupDefinitions);
  editorPreConfig = editorCode "preConfig";
  editorConfig = editorCode "config";
  extraPackages = lib.concatMap (value: value.extraPackages or [ ]) editorValues;
}
