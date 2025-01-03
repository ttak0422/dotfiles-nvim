{ self', pkgs, ... }:
let
  inherit (pkgs) callPackage;
  read = builtins.readFile;
  package = self'.packages.loaded-nvim-stable.overrideAttrs (old: {
    # git diff | sed '/^index /d' | pbcopy
    patches = [ ./version.patch ];
  });

  extraPackages = [ ];
  extraConfig = ''
    if vim.g.neovide then dofile("${../lua/autogen/neovide.lua}") end
    ${read ./../lua/autogen/prelude.lua}
  '';
  after = {
    inherit (callPackage ./after.nix { }) plugin ftplugin ftdetect;
  };
  eager = with pkgs.vimPlugins; {
    morimo.package = morimo;
    config-local.package = nvim-config-local;
    # alpha.package = pkgs.vimPlugins.alpha-nvim;
    # btw.package = pkgs.vimPlugins.btw-nvim;
  };

  lazy = {
    sorairo.package = pkgs.vimPlugins.sorairo;
    inherit (callPackage ./debug.nix { }) dap dap-go dap-ui;
    inherit (callPackage ./denops.nix { })
      ddc
      ddu
      denops
      skk
      ;
    inherit (callPackage ./diagnostic.nix { }) trouble;
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
      fix-auto-scroll
      ;
    inherit (callPackage ./hook.nix { })
      hookBuffer
      hookCmdline
      hookEdit
      hookInsert
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
      # ed-cmd
      ;
    inherit (callPackage ./language.nix { })
      lsp
      gopher
      haskell-tools
      jdtls
      nfnl
      null-ls
      rustaceanvim
      crates
      vim-nix
      vtsls
      helpview
      # MEMO: 重いので有効化しない
      # log-highlight
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
      bufsurf
      nap
      nvim-window
      foldnav
      ;
    inherit (callPackage ./outliner.nix { })
      femaco
      img-clip
      markdown-preview
      mkdnflow
      markview
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
      # tint
      vimade
      winsep
      # smear-cursor
      ;
    inherit (callPackage ./test.nix { }) neotest;
    inherit (callPackage ./tool.nix { })
      aerial
      copilot-chat
      dotfyle-metadata
      hardtime
      lir
      no-neck-pain
      oil
      other
      overseer
      pgmnt
      screenkey
      spectre
      startuptime
      translate-nvim
      window-picker
      ;
    inherit (callPackage ./treesitter.nix { })
      treesitter
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
