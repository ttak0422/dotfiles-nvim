{ pkgs, ... }:
let
  inherit (pkgs) callPackage;
  read = builtins.readFile;
  lib = callPackage ./lib.nix { };
  git = callPackage ./git.nix { };
  motion = callPackage ./motion.nix { };
  search = callPackage ./search.nix { };
  treesitter = callPackage ./treesitter.nix { };
  language = callPackage ./language.nix { };
in
with pkgs.vimPlugins;
rec {
  glance = {
    package = glance-nvim;
    postConfig = read ../lua/autogen/glance.lua;
    hooks = {
      commands = [ "Glance" ];
    };
  };
  dressing = {
    package = dressing-nvim;
    postConfig = read ../lua/autogen/dressing.lua;
    depends = [ search.telescope ];
  };
  ambiwidth = {
    package = vim-ambiwidth;
    hooks.events = [ "BufReadPost" ];
  };
  codewindow = {
    package = codewindow-nvim;
    depends = [ treesitter.treesitter ];
    postConfig = {
      code = read ../lua/autogen/codewindow.lua;
      args.exclude_ft_path = ../lua/autogen/exclude_ft.lua;
    };
    hooks.modules = [ "codewindow" ];
  };
  colorizer = {
    package = nvim-colorizer-lua;
    postConfig = read ../lua/autogen/colorizer.lua;
    hooks.commands = [ "ColorizerToggle" ];
  };
  heirline = {
    packages = [
      heirline-nvim
      # heirline-components-nvim
    ];
    depends = [
      bufferline
      lib.plenary
      git.gitsigns
      # {
      #   package = scope-nvim;
      #   postConfig = read ../lua/autogen/scope.lua;
      # }
      # deprecated
      # {
      #   package = harpoonline;
      #   depends = [ motion.harpoon ];
      #   postConfig = read ../lua/autogen/harpoonline.lua;
      # }
      {
        package = lsp-progress-nvim;
        postConfig = read ../lua/autogen/lsp-progress.lua;
      }
    ];
    postConfig = read ../lua/heirline.lua;
    hooks.events = [ "BufReadPost" ];
  };
  NeoZoom = {
    package = NeoZoom-lua;
    postConfig = read ../lua/NeoZoom.lua;
    hooks.commands = [ "NeoZoomToggle" ];
  };
  notify = {
    package = nvim-notify;
    postConfig =
      ''
        require("morimo").load("nvim-notify")
      ''
      + read ../lua/autogen/notify.lua;
    hooks.events = [ "BufReadPost" ];
  };
  noice = {
    package = noice-nvim;
    depends = [
      lib.nui
      lib.snacks
      treesitter.treesitter
      notify
      {
        package = inc-rename-nvim;
        postConfig = read ../lua/autogen/inc-rename.lua;
        hooks.commands = [ "IncRename" ];
      }
      {
        package = command-and-cursor-nvim;
        postConfig = read ../lua/autogen/command-and-cursor.lua;
      }
    ];
    postConfig = {
      code = read ../lua/noice.lua;
      args.exclude_ft_path = ../lua/autogen/exclude_ft.lua;
    };
    hooks.events = [ "BufReadPost" ];
  };
  numb = {
    package = numb-nvim;
    postConfig = read ../lua/autogen/numb.lua;
    hooks.events = [ "CmdlineEnter" ];
  };
  # tint = {
  #   package = tint-nvim;
  #   postConfig = read ../lua/autogen/tint.lua;
  #   hooks.events = [ "WinNew" ];
  # };
  vimade = {
    package = pkgs.vimPlugins.vimade;
    postConfig = read ../lua/autogen/vimade.lua;
    hooks.events = [ "WinNew" ];
  };
  winsep = {
    package = colorful-winsep-nvim;
    postConfig = {
      code = read ../lua/autogen/winsep.lua;
      args.exclude_ft_path = ../lua/autogen/exclude_ft.lua;
    };
    hooks.events = [ "WinNew" ];
  };
  dropbar = {
    package = dropbar-nvim;
    depends = [
      language.lsp
      search.telescope
      treesitter.treesitter
    ];
    postConfig = read ../lua/autogen/dropbar.lua;
    hooks = {
      events = [ "BufReadPost" ];
      modules = [ "dropbar.api" ];
    };
  };
  bufferline = {
    package = bufferline-nvim;
    depends = [
      {
        package = scope-nvim;
        postConfig = read ../lua/autogen/scope.lua;
      }
    ];
    postConfig = read ../lua/autogen/bufferline.lua;
  };
  smear-cursor = {
    package = smear-cursor-nvim;
    postConfig = read ../lua/autogen/smear-cursor.lua;
    hooks.events = [ "CursorMoved" ];
  };
}
