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
  plugin = emptyPlugin "bufferPlugins";
  dependPlugins = [
    {
      plugin = nvim-scrollbar;
      dependPlugins = [ gitsigns ];
      config = luaConfig (
        # lua
        ''
          return require("scrollbar").setup({throttle_ms = 250, handle = {blend = 0}, handlers = {gitsigns = true, cursor = false}})
        ''
      );
    }
    {
      plugin = nvim_context_vt;
      config = luaConfig (
        # lua
        ''
          local ctx_vt = require("nvim_context_vt")
          return ctx_vt.setup({prefix = "\239\129\161", priority = 10})
        ''
      );
    }
    {
      plugin = git-conflict-nvim;
      config = luaConfig (
        # lua
        ''
          local git_conflict = require("git-conflict")
          return git_conflict.setup()
        ''
      );
    }
    {
      plugin = stickybuf-nvim;
      config = luaConfig (
        # lua
        ''
          return require("stickybuf").setup()
        ''
      );
    }
    {
      plugin = nap-nvim;
      dependPlugins = [
        vim-bufsurf
        {
          plugin = marks-nvim;
          config = luaConfig (
            # lua
            ''
              local marks = require("marks")
              local sign_priority = {lower = 10, upper = 15, builtin = 8, bookmark = 20}
              return marks.setup({default_mappings = true, refresh_interval = 500, sign_priority = sign_priority})
            ''
          );
        }
      ];
      config = luaConfig (
        # lua
        ''
          local nap = require("nap")
          local diagnostic_wrn_options = {severity = {min = vim.diagnostic.severity.WARN}}
          local diagnostic_err_options = {severity = {min = vim.diagnostic.severity.ERROR}}
          local function get_qflist_nr(nr)
            return vim.fn.getqflist({nr = nr}).nr
          end
          local function safe_qf_colder()
            local idx = get_qflist_nr(0)
            if (1 < idx) then
              return vim.cmd("silent colder")
            else
              return vim.notify("reached start of quickfix list")
            end
          end
          local function safe_qf_cnewer()
            local idx = get_qflist_nr(0)
            local last_idx = get_qflist_nr("$")
            if (idx < last_idx) then
              return vim.cmd("silent cnewer")
            else
              return vim.notify("reached end of quickfix list")
            end
          end
          local operators
          local function _3_()
            return vim.diagnostic.jump(vim.tbl_extend("force", diagnostic_wrn_options, {count = 1}))
          end
          local function _4_()
            return vim.diagnostic.jump(vim.tbl_extend("force", diagnostic_wrn_options, {count = -1}))
          end
          local function _5_()
            return vim.diagnostic.jump(vim.tbl_extend("force", diagnostic_err_options, {count = 1}))
          end
          local function _6_()
            return vim.diagnostic.jump(vim.tbl_extend("force", diagnostic_err_options, {count = -1}))
          end
          local function _7_()
            return require("harpoon"):list():next()
          end
          local function _8_()
            return require("harpoon"):list():next()
          end
          operators = {b = {next = {opts = {desc = "> buffer"}, rhs = "<Cmd>bnext<CR>"}, prev = {opts = {desc = "< buffer"}, rhs = "<Cmd>bprevious<CR>"}}, B = {next = {opts = {desc = "> buffer (history)"}, rhs = "<Cmd>BufSurfForward<CR>"}, prev = {opts = {desc = "< buffer (history)"}, rhs = "<Cmd>BufSurfBack<CR>"}}, d = {next = {opts = {desc = "> warning"}, rhs = _3_}, prev = {opts = {desc = "< warning"}, rhs = _4_}}, D = {next = {opts = {desc = "> error"}, rhs = _5_}, prev = {opts = {desc = "< error"}, rhs = _6_}}, e = {next = {opts = {desc = "> edit"}, rhs = "g;"}, prev = {opts = {desc = "< edit"}, rhs = "g,"}}, j = {next = {opts = {desc = "> jump"}, rhs = "<C-i>"}, prev = {opts = {desc = "< jump"}, rhs = "<C-o>"}}, h = {next = {opts = {desc = "> harpoon"}, rhs = _7_}, prev = {opts = {desc = "< harpoon"}, rhs = _8_}}, q = {next = {opts = {desc = "> qf (item)"}, rhs = "<Cmd>Qnext<CR>"}, prev = {opts = {desc = "< qf (item)"}, rhs = "<Cmd>Qprev<CR>"}}, ["<C-q>"] = {next = {opts = {desc = "> qf (file)"}, rhs = "<Cmd>cnfile<CR>"}, prev = {opts = {desc = "< qf (file)"}, rhs = "<Cmd>cpfile<CR>"}}, ["<M-q>"] = {next = {opts = {desc = "> qf (list)"}, rhs = safe_qf_cnewer}, prev = {opts = {desc = "< qf (list)"}, rhs = safe_qf_colder}}, g = nap.gitsigns(), m = {next = {opts = {desc = "> marks"}, rhs = "<Plug>(Marks-next)"}, prev = {opts = {desc = "< marks"}, rhs = "<Plug>(Marks-prev)"}}, M = {next = {opts = {desc = "> bookmarks"}, rhs = "<Plug>(Marks-next-bookmark)"}, prev = {opts = {desc = "< bookmarks"}, rhs = "<Plug>(Marks-prev-bookmark)"}}}
          return nap.setup({next_prefix = "]", prev_prefix = "[", next_repeat = "<c-n>", prev_repeat = "<c-p>", exclude_default_operators = {"f", "F", "z", "s", "'", "l", "L", "<C-l>", "<M-l>"}, operators = operators})
        ''
      );
    }
    {
      plugin = nvim-fundo;
      dependPlugins = [
        promise-async
      ];
      config = luaConfig (
        # lua
        ''
          local fundo = require("fundo")
          return fundo.setup()
        ''
      );
    }
    {
      plugin = todo-comments-nvim;
      dependPlugins = [
        devicons
        trouble
      ];
      config = luaConfig (
        # lua
        ''
          local todo = require("todo-comments")
          return todo.setup({signs = true, keywords = {FIX = {icon = "", color = "error", alt = {"FIXME", "BUG", "FIXIT", "ISSUE"}}, TODO = {icon = "", color = "info"}, HACK = {icon = "", color = "warning"}, WARN = {icon = "", color = "warning", alt = {"WARNING", "XXX"}}, PERF = {icon = "", alt = {"OPTIM", "PERFORMANCE", "OPTIMIZE"}}, NOTE = {icon = "", color = "hint", alt = {"INFO"}}, TEST = {icon = "", color = "test", alt = {"TESTING", "PASSED", "FAILED"}}}})
        ''
      );
      extraPackages = with pkgs; [ ripgrep ];
    }
    {
      plugin = fix-auto-scroll-nvim;
      config = luaConfig (
        # lua
        ''
          require('fix-auto-scroll').setup()
        ''
      );
    }
    {
      plugin = nvim-ufo;
      dependPlugins = [
        promise-async
      ];
      config = luaConfig (
        # lua
        ''
          local ufo = require("ufo")
          local provider_selector
          local function _1_(bufnr, ft, buftype)
            local case_2_ = {bufnr, ft, buftype}
            local _ = case_2_
            return {"treesitter", "indent"}
          end
          provider_selector = _1_
          ufo.setup({provider_selector = provider_selector})
          local opts = {noremap = true, silent = true}
          local desc
          local function _3_(d)
            return {noremap = true, silent = true, desc = d}
          end
          desc = _3_
          for _, k in ipairs({{"zR", ufo.openAllFolds, desc("\239\145\188 open all folds")}, {"zr", ufo.openFoldsExceptKinds, desc("\239\145\188 open folds")}, {"zM", ufo.closeAllFolds, desc("\239\145\188 close all folds")}, {"zm", ufo.closeAllFolds, desc("\239\145\188 close all folds")}}) do
            vim.keymap.set("n", k[1], k[2], (k[3] or opts))
          end
          return nil
        ''
      );
    }
    vim-gf-improved
  ];
  config = luaConfig (
    # lua
    ''
      local cachedir = vim.fn.stdpath("cache")
      for k, v in pairs({updatetime = 100, hidden = true, autoread = true, undofile = true, undodir = (cachedir .. "/undo"), swapfile = true, directory = (cachedir .. "/swap"), backup = true, backupcopy = "yes", backupdir = (cachedir .. "/backup"), listchars = "tab:> ,trail:-", list = true, equalalways = false, startofline = false}) do
        vim.opt[k] = v
      end
      local opts = {noremap = true, silent = true}
      local desc
      local function _1_(d)
        return {noremap = true, silent = true, desc = d}
      end
      desc = _1_
      local toggle
      local function _2_(id)
        local function _3_()
          return require("toggler").toggle(id)
        end
        return _3_
      end
      toggle = _2_
      local function _4_()
        return require("open").open_cword()
      end
      local function _5_()
        return require("dap").toggle_breakpoint()
      end
      local function _6_()
        return require("dap").repl.toggle()
      end
      local function _7_()
        return require("dap").run_last()
      end
      for _, k in ipairs({{"<Leader>tz", "<Cmd>NeoZoomToggle<CR>", desc("\239\136\132 zoom")}, {"<Leader>tm", "<Cmd>lua require('codewindow').toggle_minimap()<CR>", desc("\239\136\132 minimap")}, {"<Leader>to", toggle("aerial"), desc("\239\136\132 outline")}, {"<Leader>U", "<Cmd>Atone<CR>", desc("\239\136\132 undotree")}, {"gx", _4_, desc("open")}, {"<Leader>gb", "<Cmd>BlameToggle<CR>", desc("\239\135\147 blame")}, {"<LocalLeader>db", _5_, desc("\238\171\152 breakpoint")}, {"<LocalLeader>dr", _6_, desc("\238\171\152 repl")}, {"<LocalLeader>dl", _7_, desc("\238\171\152 run last")}, {"<LocalLeader>dd", toggle("dapui"), desc("\238\171\152 run last")}}) do
        vim.keymap.set("n", k[1], k[2], (k[3] or opts))
      end
      return nil
    ''
  );
  doc = "Enabled v2/default bufferPlugins configuration, loaded at startup. See the migration inventory in the core cartridge documentation.";
}
