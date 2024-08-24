{ self', pkgs, ... }:
let
  inherit (pkgs) callPackage;
  read = builtins.readFile;
  # package = self'.packages.loaded-nvim-nightly.overrideAttrs (old: {
  #   # git diff | sed '/^index /d' | pbcopy
  #   patches = [ ./version.patch ];
  # });
  package = pkgs.neovim-unwrapped;

  extraPackages = [ ];
  extraConfig = ''
    if vim.g.neovide then
      dofile("${../lua/autogen/neovide.lua}")
    end
    ${read ./../lua/autogen/prelude.lua}
  '';
  after = {
    inherit (callPackage ./after.nix { }) plugin ftplugin;
  };
  eager = {
    morimo.package = pkgs.vimPlugins.morimo;
    config-local.package = pkgs.vimPlugins.nvim-config-local;
    # alpha.package = pkgs.vimPlugins.alpha-nvim;
    # btw.package = pkgs.vimPlugins.btw-nvim;
  };

  lazy = {
    inherit (callPackage ./debug.nix { }) dap dap-go dap-ui;
    inherit (callPackage ./denops.nix { })
      ddc
      ddu
      denops
      gin
      skk
      translate
      ;
    inherit (callPackage ./diagnostic.nix { }) dd trouble;
    inherit (callPackage ./git.nix { })
      diffview
      gina
      git-conflict
      gitsigns
      neogit
      octo
      ;
    inherit (callPackage ./helper.nix { })
      direnv
      fundo
      history-ignore
      lastplace
      mkdir
      open
      project
      registers
      smart-splits
      stickybuf
      todo-comments
      toolwindow
      trim
      vimdoc-ja
      waitevent
      whichkey
      winshift
      bufdel
      ;
    inherit (callPackage ./hook.nix { })
      hookBuffer
      hookCmdline
      hookEdit
      hookInsert
      hookLeader
      hookWindow
      hookTerm
      ;
    inherit (callPackage ./input.nix { })
      # cmp
      treesj
      autopairs
      better-escape
      comment
      indent-o-matic
      tabout
      undotree
      ;
    inherit (callPackage ./language.nix { })
      lsp
      gopher
      haskell-tools
      jdtls
      nfnl
      null-ls
      rustaceanvim
      vim-nix
      vtsls
      ;
    inherit (callPackage ./lib.nix { })
      plenary
      nio
      nui
      devicons
      ;
    inherit (callPackage ./motion.nix { })
      detour
      leap
      flit
      goto-preview
      harpoon
      hydra
      marks
      BufferBrowser
      nap
      nvim-window
      ;
    inherit (callPackage ./outliner.nix { })
      femaco
      img-clip
      markdown-preview
      mkdnflow
      venn
      neorg
      ;
    inherit (callPackage ./quickfix.nix { }) bqf qf qfreplace;
    inherit (callPackage ./search.nix { })
      telescope
      asterisk
      hlslens
      legendary
      reacher
      fzf
      ;
    inherit (callPackage ./snippet.nix { })
      # LuaSnip
      flow
      neogen
      sonictemplate
      vsnip
      ;
    inherit (callPackage ./style.nix { })
      NeoZoom
      ambiwidth
      codewindow
      colorizer
      dressing
      dropbar
      glance
      heirline
      noice
      notify
      numb
      statuscol
      tint
      winsep
      ;
    inherit (callPackage ./test.nix { }) neotest;
    inherit (callPackage ./tool.nix { })
      jabs
      toggleterm
      overseer
      spectre
      startuptime
      window-picker
      lir
      oil
      ;
    inherit (callPackage ./treesitter.nix { })
      treesitter
      auto-indent
      context-vt
      hlchunk
      ts-autotag
      ;
  };
in
{
  inherit
    package
    extraPackages
    extraConfig
    after
    eager
    lazy
    ;
}
