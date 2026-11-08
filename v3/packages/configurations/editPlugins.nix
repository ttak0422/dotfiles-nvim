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
  plugin = emptyPlugin "editPlugins";
  dependPlugins = [
    {
      plugin = visual-whitespace-nvim;
      config = luaConfig (
        # lua
        ''

        ''
      );
    }
    {
      plugin = tiny-glimmer-nvim;
      config = luaConfig (
        # lua
        ''
          local glimmer = require("tiny-glimmer")
          local overwrite = {search = {enabled = false}, paste = {enabled = true}, yank = {enabled = true}, undo = {enabled = true}, redo = {enabled = true}}
          return glimmer.setup({enabled = true, overwrite = overwrite})
        ''
      );
    }
    {
      plugin = which-key-nvim;
      dependPlugins = [
        devicons
      ];
      config = luaConfig (
        # lua
        ''
          local wk = require("which-key")
          local function delay(ctx)
            if ctx.plugin then
              return 50
            else
              return 200
            end
          end
          local icons = {mappins = true, rules = false}
          return wk.setup({preset = "helix", delay = delay, icons = icons})
        ''
      );
    }
    {
      plugin = hydra-nvim;
      config = luaConfig (
        # lua
        ''
          local hydra = require("hydra")
          local float_opts = {border = "single"}
          local saved = {}
          hydra.setup({timeout = false})
          local function draw(direction)
            return require("draw-line").draw(direction)
          end
          local function box(style)
            local ok, err = require("draw-line").box_visual(style)
            if not ok then
              return vim.notify(err, vim.log.levels.WARN)
            else
              return nil
            end
          end
          local heads
          local function _2_()
            return draw("h")
          end
          local function _3_()
            return draw("j")
          end
          local function _4_()
            return draw("k")
          end
          local function _5_()
            return draw("l")
          end
          local function _6_()
            return box("double")
          end
          local function _7_()
            return box("single")
          end
          local function _8_()
            return box("heavy")
          end
          heads = {{"H", _2_}, {"J", _3_}, {"K", _4_}, {"L", _5_}, {"r", _6_, {mode = "x"}}, {"f", _7_, {mode = "x"}}, {"v", _8_, {mode = "x"}}, {"<Esc>", nil, {desc = "close", exit = true}}}
          local config
          local function _9_()
            saved.win = vim.api.nvim_get_current_win()
            saved.virtualedit = vim.wo.virtualedit
            saved.selection = vim.o.selection
            vim.api.nvim_set_option_value("virtualedit", "all", {scope = "local"})
            return vim.api.nvim_set_option_value("selection", "inclusive", {})
          end
          local function _10_()
            if vim.api.nvim_win_is_valid(saved.win) then
              vim.api.nvim_set_option_value("virtualedit", saved.virtualedit, {win = saved.win, scope = "local"})
            else
            end
            return vim.api.nvim_set_option_value("selection", saved.selection, {})
          end
          config = {invoke_on_body = true, color = "pink", on_enter = _9_, on_exit = _10_, hint = {type = "window", position = "bottom-right", float_opts = float_opts}}
          local hint = ":Move    Select region with <C-v>\n-------  -------------------------\n   _K_     _r_: surround double\n _H_   _L_   _f_: surround single\n   _J_     _v_: surround bold"
          return hydra({name = "Draw Diagram", mode = "n", body = "<Leader>V", heads = heads, config = config, hint = hint})
        ''
      );
    }
    {
      plugin = nvim-autopairs;
      config = luaConfig (
        # lua
        ''
          local autopairs = require("nvim-autopairs")
          local rule = require("nvim-autopairs.rule")
          autopairs.setup({map_cr = true, check_ts = true, ts_config = {go = false}, disable_filetype = {"TelescopePrompt", "spectre_panel", "norg"}})
          return autopairs.add_rules({rule("\"\"\"", "\"\"\"", "java")})
        ''
      );
    }
    {
      plugin = guess-indent-nvim;
      config = luaConfig (
        # lua
        ''
          local guess_indent = require("guess-indent")
          return guess_indent.setup({auto_cmd = true, filetype_exclude = {"netrw", "tutor"}, buftype_exclude = {"help", "nofile", "terminal", "prompt"}, on_tab_options = {expandtab = false}, on_space_options = {expandtab = true, tabstop = "detected", softtabstop = "detected", shiftwidth = "detected"}, override_editorconfig = false})
        ''
      );
    }
    {
      plugin = nvim-dd;
      config = luaConfig (
        # lua
        ''
          local dd = require("dd")
          return dd.setup()
        ''
      );
    }
    {
      plugin = trim-nvim;
      config = luaConfig (
        # lua
        ''
          local trim = require("trim")
          return trim.setup({ft_blocklist = {"markdown", "neorg", "norg"}})
        ''
      );
    }
    {
      plugin = hlchunk-nvim;
      config = luaConfig (
        # lua
        ''
          local hlchunk = require("hlchunk")
          local indent = {enable = false}
          local line_num = {enable = false}
          local blank = {enable = false}
          local chunk = {enable = true, chars = {horizontal_line = "\226\148\128", vertical_line = "\226\148\130", left_top = "\226\148\140", left_bottom = "\226\148\148", right_arrow = "\226\148\128"}, style = vim.g.terminal_color_8, duration = 200, delay = 500, use_treesitter = true, exclude_filetypes = {["copilot-chat"] = true}}
          return hlchunk.setup({chunk = chunk, indent = indent, line_num = line_num, blank = blank})
        ''
      );
    }
    {
      plugin = better-escape-nvim;
      config = luaConfig (
        # lua
        ''
          local be = require("better_escape")
          return be.setup({mappings = {i = {j = {k = "<Esc>"}}, c = {}, t = {j = {k = "<C-\\><C-n>"}}, v = {}, s = {}}, default_mappings = false})
        ''
      );
    }
    {
      plugin = nvim-surround;
      config = luaConfig (
        # lua
        ''
          vim.g.nvim_surround_no_insert_mappings = true
          vim.g.nvim_surround_no_normal_mappings = true
          vim.g.nvim_surround_no_visual_mappings = true
          local surround = require("nvim-surround")
          surround.setup({})
          local function map(mode, lhs, rhs, desc)
            return vim.keymap.set(mode, lhs, rhs, {noremap = true, silent = true, desc = desc})
          end
          for _, _1_ in ipairs({{"i", "<C-g>s", "<Plug>(nvim-surround-insert)", "Add a surrounding pair around the cursor (insert mode)"}, {"i", "<C-g>S", "<Plug>(nvim-surround-insert-line)", "Add a surrounding pair around the cursor, on new lines (insert mode)"}, {"n", "ys", "<Plug>(nvim-surround-normal)", "Add a surrounding pair around a motion (normal mode)"}, {"n", "yss", "<Plug>(nvim-surround-normal-cur)", "Add a surrounding pair around the current line (normal mode)"}, {"n", "yS", "<Plug>(nvim-surround-normal-line)", "Add a surrounding pair around a motion, on new lines (normal mode)"}, {"n", "ySS", "<Plug>(nvim-surround-normal-cur-line)", "Add a surrounding pair around the current line, on new lines (normal mode)"}, {"x", "Y", "<Plug>(nvim-surround-visual)", "Add a surrounding pair around a visual selection"}, {"x", "gY", "<Plug>(nvim-surround-visual-line)", "Add a surrounding pair around a visual selection, on new lines"}, {"n", "ds", "<Plug>(nvim-surround-delete)", "Delete a surrounding pair"}, {"n", "cs", "<Plug>(nvim-surround-change)", "Change a surrounding pair"}, {"n", "cS", "<Plug>(nvim-surround-change-line)", "Change a surrounding pair, on new lines"}}) do
            local mode = _1_[1]
            local lhs = _1_[2]
            local rhs = _1_[3]
            local desc = _1_[4]
            map(mode, lhs, rhs, desc)
          end
          return nil
        ''
      );
    }
    {
      plugin = dmacro-vim;
      config = luaConfig ({
        code = # vim
          ''
            inoremap <C-q> <Plug>(dmacro-play-macro)
            nnoremap <C-q> <Plug>(dmacro-play-macro)
          '';
        language = "vim";
      });
    }
    {
      plugin = switch-vim;
      preConfig = luaConfig ({
        language = "vim";
        code = # vim
          ''
            let g:switch_mapping = '-'
          '';
      });
    }
    {
      plugin = emptyPlugin "editPlugins-13";
      dependPlugins = [
        leap-nvim
        vim-repeat
      ];
      config = luaConfig (
        # lua
        ''
          local M = require("leap")
          local clever = require("leap.user").with_traversal_keys
          local clever_f = clever("f", "F")
          local clever_t = clever("t", "T")
          local function ft(spec)
            local _1_
            if vim.fn.mode(1):match("o") then
              _1_ = ""
            else
              _1_ = nil
            end
            return M.leap(vim.tbl_deep_extend("keep", spec, {inputlen = 1, inclusive = true, opts = {labels = "", safe_labels = _1_}}))
          end
          for modes, _3_ in pairs({[{"n", "x", "o"}] = {"s", "<Plug>(leap)", "Leap"}, n = {"S", "<Plug>(leap-from-window)", "Leap from window"}}) do
            local lhs = _3_[1]
            local rhs = _3_[2]
            local desc = _3_[3]
            vim.keymap.set(modes, lhs, rhs, {noremap = true, silent = true, desc = desc})
          end
          for key, spec in pairs({f = {opts = clever_f}, F = {backward = true, opts = clever_f}, t = {offset = -1, opts = clever_t}, T = {backward = true, offset = 1, opts = clever_t}}) do
            local function _4_()
              return ft(spec)
            end
            vim.keymap.set({"n", "x", "o"}, key, _4_)
          end
          for modes, _5_ in pairs({[{"n", "x", "o"}] = {"s", "<Plug>(leap)", "Leap"}, n = {"S", "<Plug>(leap-from-window)", "Leap from window"}}) do
            local lhs = _5_[1]
            local rhs = _5_[2]
            local desc = _5_[3]
            vim.keymap.set(modes, lhs, rhs, {noremap = true, silent = true, desc = desc})
          end
          return nil
        ''
      );
    }
    {
      plugin = fidget-nvim;
      config = luaConfig (
        # lua
        ''
          return require("fidget").setup({})
        ''
      );
    }
    {
      plugin = nvim-notify;
      config = luaConfig (
        # lua
        ''
          local notify = require("notify")
          notify.setup({timeout = 2500, render = "default", top_down = true, stages = "static", background_colour = "#000000"})
          vim.notify = notify
          return nil
        ''
      );
    }
  ];
  config = luaConfig (
    # lua
    ''
            vim.cmd([=[
      cabbrev <expr> wq getcmdtype() .. getcmdline() ==# ":wq" && &ft == "gitcommit" ? "w \| b#" : "wq"
      ]=])
    ''
    # lua
    + ''
      vim.cmd("\nau FileType * setlocal formatoptions-=ro\nau WinEnter * checktime\nvnoremap ; :\nnnoremap ; :\nnoremap gy \"+y\ninoremap <C-l> <Nop>\n")
      local opts = {noremap = true, silent = true}
      local desc
      local function _1_(d)
        return {noremap = true, silent = true, desc = d}
      end
      desc = _1_
      local dial
      local function _2_(direction, mode)
        local function _3_()
          return require("dial.map").manipulate(direction, mode)
        end
        return _3_
      end
      dial = _2_
      local function _4_()
        return require("treesj").toggle({split = {recursive = false}})
      end
      local function _5_()
        return require("treesj").toggle({split = {recursive = true}})
      end
      local function _6_()
        return require("foldnav").goto_start()
      end
      local function _7_()
        return require("foldnav").goto_next()
      end
      local function _8_()
        return require("foldnav").goto_prev_start()
      end
      local function _9_()
        return require("foldnav").goto_end()
      end
      for _, k in ipairs({{"<Leader>m", _4_, desc("\239\136\132 join/split")}, {"<Leader>M", _5_, desc("\239\136\132 join/split (recursive)")}, {"<Leader>O", "<Cmd>Other<CR>"}, {"<Left>", _6_}, {"<Down>", _7_}, {"<Up>", _8_}, {"<Right>", _9_}, {"<C-a>", dial("increment", "normal")}, {"<C-x>", dial("decrement", "normal")}, {"g<C-a>", dial("increment", "gnormal")}, {"g<C-x>", dial("decrement", "gnormal")}}) do
        vim.keymap.set("n", k[1], k[2], (k[3] or opts))
      end
      for _, k in ipairs({{"<Leader>T", ":Translate JA<CR>"}, {"<C-a>", dial("increment", "visual")}, {"<C-x>", dial("decrement", "visual")}, {"g<C-a>", dial("increment", "gvisual")}, {"g<C-x>", dial("decrement", "gvisual")}}) do
        vim.keymap.set("x", k[1], k[2], (k[3] or opts))
      end
      return nil
    ''
  );
  doc = "Enabled v2/default editPlugins configuration, loaded at startup. See the migration inventory in the core cartridge documentation.";
}
