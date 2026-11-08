{
  pkgs,
  lib,
  sources,
  definitions,
  luaConfig,
  emptyPlugin,
  inputs',
}:
with sources;
with definitions;
{
  plugin = emptyPlugin "modulePlugins";
  dependPlugins = [
    {
      plugin = tiny-code-action-nvim.overrideAttrs {
        runtimeDeps = with pkgs; [ delta ];
      };
      config = luaConfig (
        # lua
        ''
          return require("tiny-code-action").setup({backend = "delta", picker = {"telescope", opts = {winborder = "single"}}})
        ''
      );
    }
    {
      plugin = dial-nvim;
      config = luaConfig (
        # lua
        ''
          local config = require("dial.config")
          local augend = require("dial.augend")
          local default = {augend.integer.alias.decimal, augend.integer.alias.hex, augend.date.alias["%Y/%m/%d"], augend.date.alias["%Y-%m-%d"], augend.constant.alias.bool, augend.semver.alias.semver}
          return config.augends:register_group({default = default})
        ''
      );
    }
    {
      plugin = lookup-nvim;
      dependPlugins = [
        telescope
      ];
      config = luaConfig (
        # lua
        ''
          local lookup = require("lookup")
          return lookup.setup({use_lsp = true, picker = "telescope"})
        ''
      );
    }
    {
      plugin = goto-preview;
      config = luaConfig (
        # lua
        ''
          local _goto = require("goto-preview")
          return _goto.setup({height = 20, width = 120, zindex = 90, border = "single", default_mappings = false, resizing_mappings = false})
        ''
      );
    }
    {
      plugin = nvim-spectre;
      dependPlugins = [
        plenary
        devicons
      ];
      config = luaConfig (
        # lua
        ''
          local spectre = require("spectre")
          return spectre.setup({default = {find = {cmd = "rg", options = {}}, replace = {cmd = "sd"}}, color_devicons = false, is_block_ui_break = false, live_update = false})
        ''
      );
      extraPackages = with pkgs; [
        ripgrep
        sd
      ];
    }
    {
      plugin = aerial-nvim;
      config = luaConfig (
        # lua
        ''
          local aerial = require("aerial")
          local filter_kind = {"Class", "Constructor", "Enum", "Function", "Method", "Interface", "Module", "Method", "Struct"}
          local float = {border = "single", relative = "cursor", max_height = 0.9, min_height = {8, 0.1}}
          local guides = {mid_item = "\226\148\156\226\148\128", last_item = "\226\148\148\226\148\128", nested_top = "\226\148\130 ", whitespace = "  "}
          local icons = {Text = "\243\176\137\191", Method = "\243\176\138\149", Function = "\243\176\138\149", Constructor = "\243\176\146\147", Field = "\243\176\156\162", Variable = "\243\176\128\171", Class = "\243\176\160\177", Interface = "\239\131\168", Module = "\239\146\135", Property = "\243\176\156\162", Unit = "\238\170\150", Value = "\243\176\142\160", Enum = "\239\133\157", Keyword = "\243\176\140\139", Snippet = "\239\145\143", Color = "\243\176\143\152", File = "\243\176\136\148", Reference = "\243\176\136\135", Folder = "\243\176\137\139", EnumMember = "\239\133\157", Constant = "\243\176\143\191", Struct = "\243\176\153\133", Event = "\243\177\144\139", Operator = "\243\176\134\149", TypeParameter = "\243\176\151\180"}
          local ignore = {diff_windows = true, filetypes = {}, buftypes = "special", wintypes = "special", unlisted_buffers = false}
          local keymaps = {["g?"] = "actions.show_help", ["<CR>"] = "actions.jump", ["<2-LeftMouse>"] = "actions.jump", ["<C-v>"] = "actions.jump_vsplit", ["<C-s>"] = "actions.jump_split", p = "actions.scroll", ["<C-j>"] = "actions.down_and_scroll", ["<C-k>"] = "actions.up_and_scroll", ["{"] = "actions.prev", ["}"] = "actions.next", ["[["] = "actions.prev_up", ["]]"] = "actions.next_up", q = "actions.close", o = "actions.tree_toggle", za = "actions.tree_toggle", O = "actions.tree_toggle_recursive", zA = "actions.tree_toggle_recursive", l = "actions.tree_open", zo = "actions.tree_open", L = "actions.tree_open_recursive", zO = "actions.tree_open_recursive", h = "actions.tree_close", zc = "actions.tree_close", H = "actions.tree_close_recursive", zC = "actions.tree_close_recursive", zr = "actions.tree_increase_fold_level", zR = "actions.tree_open_all", zm = "actions.tree_decrease_fold_level", zM = "actions.tree_close_all", zx = "actions.tree_sync_folds", zX = "actions.tree_sync_folds"}
          local layout = {max_width = 0.8, min_width = 0.15, default_direction = "float", placement = "window"}
          local lsp = {update_when_errors = true, update_delay = 600, diagnostics_trigger_update = false}
          local treesitter = {update_delay = 500}
          local backends = {"treesitter", "lsp"}
          return aerial.setup({filter_kind = filter_kind, float = float, guides = guides, icons = icons, ignore = ignore, keymaps = keymaps, layout = layout, lsp = lsp, treesitter = treesitter, backends = backends})
        ''
      );
    }
    {
      plugin = goto-preview;
      config = luaConfig (
        # lua
        ''
          local _goto = require("goto-preview")
          return _goto.setup({height = 20, width = 120, zindex = 90, border = "single", default_mappings = false, resizing_mappings = false})
        ''
      );
    }
    {
      plugin = emptyPlugin "modulePlugins-7";
      dependPlugins = [
        nvim-jdtls
        spring-boot-nvim
        dap
        dap-ui
      ];
      config = luaConfig (
        # lua
        ''
          local function _1_()
            local root_dir = vim.fs.root(0, {"gradlew", "mvnw", ".git"})
            local workspace_dir = (os.getenv("HOME") .. "/.local/share/eclipse/" .. string.gsub(vim.fn.fnamemodify(root_dir, ":p:h"), "/", "_"))
            vim.notify("Starting to delete JDTLS workspace data.")
            os.execute(("rm -rf " .. workspace_dir))
            return vim.notify("JDTLS workspace data deleted.")
          end
          return vim.api.nvim_create_user_command("JdtDelteteWorkspaceData", _1_, {})
        ''
      );
    }
    {
      plugin = open-nvim;
      config = luaConfig (''
        require("open").setup({
          system_open = {
            cmd = "${if pkgs.stdenv.isDarwin then "open" else "xdg-open"}",
            args = {},
          }
        })
      '');
    }
    {
      plugin = treesj;
      config = luaConfig (
        # lua
        ''
          local tsj = require("treesj")
          return tsj.setup({use_default_keymaps = false})
        ''
      );
    }
    {
      plugin = codewindow-nvim;
      dependPlugins = [
        bufferPlugins
      ];
      config = luaConfig (
        # lua
        ''
          local codewindow = require("codewindow")
          return codewindow.setup({exclude_filetypes = {"undotree", "gitsigns-blame"}, max_minimap_height = nil, max_lines = nil, minimap_width = 10, use_lsp = true, use_treesitter = true, use_git = true, width_multiplier = 4, z_index = 1, show_cursor = true, window_border = "none", relative = "editor", events = {"TextChanged", "InsertLeave", "DiagnosticChanged", "FileWritePost"}, active_in_terminals = false, auto_enable = false})
        ''
      );
    }
    {
      plugin = nvim-window;
      config = luaConfig (
        # lua
        ''
          local window = require("nvim-window")
          return window.setup({})
        ''
      );
    }
    {
      plugin = foldnav-nvim;
    }
  ];
  doc = "Enabled v2/default modulePlugins configuration, loaded at startup. See the migration inventory in the core cartridge documentation.";
}
