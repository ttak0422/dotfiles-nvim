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
    hooks.userEvents = [ "SpecificFileEnter" ];
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
      lib.plenary
      git.gitsigns
      {
        package = scope-nvim;
        postConfig = read ../lua/autogen/scope.lua;
      }
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
    hooks.userEvents = [ "SpecificFileEnter" ];
  };
  NeoZoom = {
    package = NeoZoom-lua;
  };
  notify = {
    package = nvim-notify;
    postConfig = read ../lua/autogen/notify.lua;
    hooks.userEvents = [ "SpecificFileEnter" ];
  };
  noice = {
    package = noice-nvim;
    depends = [
      lib.nui
      treesitter.treesitter
      notify
    ];
    postConfig = {
      code = read ../lua/autogen/noice.lua;
      args.exclude_ft_path = ../lua/autogen/exclude_ft.lua;
    };
    hooks.userEvents = [ "SpecificFileEnter" ];
  };
  numb = {
    package = numb-nvim;
    postConfig = read ../lua/autogen/numb.lua;
    hooks.events = [ "CmdlineEnter" ];
  };
  statuscol = {
    package = statuscol-nvim;
    postConfig = read ../lua/autogen/statuscol.lua;
    depends = [
      {
        package = nvim-ufo;
        depends = [
          promise-async
          treesitter.treesitter
        ];
        postConfig = read ../lua/autogen/ufo.lua;
      }
    ];
    hooks.userEvents = [ "SpecificFileEnter" ];
  };
  tint = {
    package = tint-nvim;
    postConfig = read ../lua/autogen/tint.lua;
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
      userEvents = [ "SpecificFileEnter" ];
      modules = [ "dropbar.api" ];
    };
  };
}
