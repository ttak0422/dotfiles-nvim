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
let
  mimori = inputs'.v2-mimori.packages.default;
in
{
  plugin = emptyPlugin "commandPlugins";
  dependPlugins = [
    {
      plugin = pterm;
      dependPlugins = [ telescope ];
      config = luaConfig (
        # lua
        ''
          require("pterm").setup({})
          require("telescope").load_extension("pterm")
          local pterm = require("pterm")
          local telescope = require("telescope")
          local actions = require("telescope.actions")
          local action_state = require("telescope.actions.state")
          local parser = require("telescope-live-grep-args.prompt_parser")
          telescope.load_extension("pterm")
          local function create_session(prompt_bufnr)
            local prompt = vim.trim(action_state.get_current_line())
            local names = pterm.list()
            local argv
            if vim.tbl_contains(names, prompt) then
              argv = {prompt}
            else
              argv = parser.parse(prompt, false)
            end
            local name = argv[1]
            local command = argv[2]
            if ((name == nil) or (name == "")) then
              return actions.close(prompt_bufnr)
            elseif (command and vim.tbl_contains(names, name)) then
              return vim.notify(("Session '" .. name .. "' already exists; select it without a command"), vim.log.levels.ERROR)
            elseif (command and (vim.fn.executable(command) == 0)) then
              return vim.notify(("Executable not found: " .. command), vim.log.levels.ERROR)
            else
              actions.close(prompt_bufnr)
              local ok, err = pcall(pterm.open, name, argv)
              if not ok then
                return vim.notify(("Failed to open session '" .. name .. "': " .. tostring(err)), vim.log.levels.ERROR)
              else
                return nil
              end
            end
          end
          local extension = telescope.extensions.pterm
          local sessions = extension.sessions
          local configured
          local function _4_(opts)
            local opts0 = vim.tbl_extend("force", {}, (opts or {}))
            local attach = opts0.attach_mappings
            opts0.prompt_title = (opts0.prompt_title or "pterm sessions | new: name [command args...]")
            local function _5_(prompt_bufnr, map)
              local function _6_()
                return (action_state.get_selected_entry() == nil)
              end
              local function _7_()
                return create_session(prompt_bufnr)
              end
              actions.select_default:replace_if(_6_, _7_)
              if attach then
                return attach(prompt_bufnr, map)
              else
                return true
              end
            end
            opts0.attach_mappings = _5_
            return sessions(opts0)
          end
          configured = _4_
          extension.sessions = configured
          extension.pterm = configured
          return nil
        ''
      );
      extraPackages = with pkgs; [ pterm-daemon ];
    }
    {
      plugin = other-nvim;
      config = luaConfig (
        # lua
        ''
          local other = require("other-nvim")
          local transformers = require("other-nvim.builtin.transformers")
          local mappings = {"c", "clojure", "elixir", "golang", "python", "react", "rust"}
          local transformers0 = {camelToKebap = transformers.camelToKebap, kebapToCamel = transformers.kebapToCamel, pluralize = transformers.pluralize, singularize = transformers.singularize}
          local keybindings = {["<cr>"] = "open_file_by_command()", ["<esc>"] = "close_window()", ["<C-w>o"] = "open_file()", ["<C-w>t"] = "open_file_tabnew()", ["<C-w>q"] = "close_window()", ["<C-w>v"] = "open_file_vs()", ["<C-w>s"] = "open_file_sp()"}
          return other.setup({showMissingFiles = true, mappings = mappings, transformers = transformers0, keybindings = keybindings, rememberBuffers = false})
        ''
      );
    }
    {
      plugin = actually-doom-nvim;
    }
    {
      plugin = replua-nvim;
      config = luaConfig (
        # lua
        ''
          return require("replua").setup({keymaps = {eval_line = "<LocalLeader>rl", eval_block = "<LocalLeader>rr", eval_buffer = "<LocalLeader>rA"}})
        ''
      );
    }
    {
      plugin = blame-nvim;
      config = luaConfig (
        # lua
        ''
          local blame = require("blame")
          local mappings = {commit_info = "i", stack_push = "<TAB>", stack_pop = "<BS>", show_commit = "<CR>", close = {"<esc>", "q"}}
          return blame.setup({date_format = "%Y-%m-%d", virtual_style = "right_align", focus_blame = true, max_summary_width = 30, colors = nil, blame_options = nil, commit_detail_view = "vsplit", mappings = mappings, merge_consecutive = false, relative_date_if_recent = false})
        ''
      );
    }
    {
      plugin = fyler-nvim;
      dependPlugins = [
        devicons
      ];
      config = luaConfig (
        # lua
        ''
          return require("fyler").setup({close_on_select = true, icon_provider = "nvim_web_devicons", win = {border = "single", kind = "replace", buf_opts = {}, win_opts = {number = false, relativenumber = false}}})
        ''
      );
    }
    {
      plugin = nvim-aibo;
      config = luaConfig (
        # lua
        ''
          local aibo = require("aibo")
          local prompt
          local function _1_(bufnr, _info)
            for mode, maps in pairs({[{"n", "i"}] = {["<C-n>"] = "<Plug>(aibo-send)<C-n>", ["<C-p>"] = "<Plug>(aibo-send)<C-p>", ["<Down>"] = "<Plug>(aibo-send)<Down>", ["<Up>"] = "<Plug>(aibo-send)<Up>", ["<C-c>"] = "<Plug>(aibo-send)<Esc>"}, [{"n"}] = {["<CR>"] = "<Plug>(aibo-submit)"}, [{"i"}] = {["<C-s>"] = "<Plug>(aibo-submit)"}}) do
              for k, v in pairs(maps) do
                vim.keymap.set(mode, k, v, {buf = bufnr, nowait = true, silent = true})
              end
            end
            return nil
          end
          prompt = {on_attach = _1_, no_default_mappings = false}
          local console
          local function _2_(_bufnr, _info)
          end
          console = {on_attach = _2_, no_default_mappings = false}
          local tools
          local function _3_(_bufnr, _info)
          end
          tools = {claude = {on_attach = _3_, no_default_mappings = false}, codex = {}}
          return aibo.setup({prompt = prompt, console = console, tools = tools})
        ''
      );
    }
    {
      plugin = videre-nvim;
      dependPlugins = [
        graph_view_yaml_parser
        graph_view_toml_parser
      ];
      config = luaConfig (
        # lua
        ''
          local videre = require("videre")
          return videre.setup({editor_type = "floating", box_style = "sharp"})
        ''
      );
    }
    {
      plugin = no-neck-pain-nvim;
      config = luaConfig (
        # lua
        ''
          local nnp = require("no-neck-pain")
          return nnp.setup({buffers = {right = {enabled = false}}})
        ''
      );
    }
    {
      plugin = lush-nvim;
    }
    {
      plugin = nvim-colorizer-lua;
      config = luaConfig (
        # lua
        ''
          return require("colorizer").setup()
        ''
      );
    }
    {
      plugin = draw-line-nvim;
    }
    {
      plugin = claudecode-nvim;
      config = luaConfig (
        # lua
        ''
          local claude = require("claudecode")
          local terminal = {split_side = "right", split_width_percentage = 0.45, provider = "auto", auto_close = true}
          local keys = {}
          return claude.setup({terminal = terminal, keys = keys})
        ''
      );
    }
    {
      plugin = emptyPlugin "commandPlugins-14";
      dependPlugins = [
        inputPlugins
      ];
      extraPackages = with pkgs; [
        pkgs-stable.gitu
      ];
      config = luaConfig (
        # lua
        ''
          local augroup = vim.api.nvim_create_augroup("ttak-gitu", {clear = false})
          local gitu_pattern = "term://.*:gitu$"
          local function gitu_buffer_3f(buf)
            local and_1_ = vim.api.nvim_buf_is_valid(buf)
            if and_1_ then
              local or_2_ = (true == vim.b[buf].gitu)
              if not or_2_ then
                local name = vim.api.nvim_buf_get_name(buf)
                or_2_ = (name:match(gitu_pattern) and true)
              end
              and_1_ = or_2_
            end
            return and_1_
          end
          local function gitu_running_buffer_3f(buf)
            return (gitu_buffer_3f(buf) and (true == vim.b[buf].gitu_running))
          end
          local function normal_win_count()
            local count = 0
            for _, win in ipairs(vim.api.nvim_list_wins()) do
              if ("" == vim.api.nvim_win_get_config(win).relative) then
                count = (count + 1)
              else
              end
            end
            return count
          end
          local function split_for_gitu()
            local width = vim.o.columns
            local height = vim.o.lines
            if ((width / height) > 2.5) then
              return vim.cmd("vsplit")
            else
              return vim.cmd("split")
            end
          end
          local function startinsert_if_current(buf)
            local function _6_()
              if (vim.api.nvim_buf_is_valid(buf) and (vim.api.nvim_get_current_buf() == buf)) then
                return vim.cmd("startinsert")
              else
                return nil
              end
            end
            return vim.schedule(_6_)
          end
          local function with_editor_origin(win, buf, f)
            local prev_editor_win = vim.env.NVIM_EDITOR_WIN
            local prev_editor_buf = vim.env.NVIM_EDITOR_BUF
            local prev_editor_use_origin = vim.env.NVIM_EDITOR_USE_ORIGIN
            vim.env.NVIM_EDITOR_USE_ORIGIN = "1"
            vim.env.NVIM_EDITOR_WIN = tostring(win)
            vim.env.NVIM_EDITOR_BUF = tostring(buf)
            local ok_3f, result = pcall(f)
            vim.env.NVIM_EDITOR_USE_ORIGIN = prev_editor_use_origin
            vim.env.NVIM_EDITOR_WIN = prev_editor_win
            vim.env.NVIM_EDITOR_BUF = prev_editor_buf
            if ok_3f then
              return result
            else
              return error(result)
            end
          end
          local function focus_gitu_buffer(buf)
            do
              local wins = vim.fn.win_findbuf(buf)
              if (#wins > 0) then
                vim.api.nvim_set_current_win(wins[1])
              else
                if (normal_win_count() == 1) then
                  split_for_gitu()
                else
                end
                vim.api.nvim_win_set_buf(0, buf)
              end
            end
            return startinsert_if_current(buf)
          end
          local function delete_gitu_buffer(buf)
            local function _11_()
              return require("snacks").bufdelete({buf = buf, force = true})
            end
            return pcall(_11_)
          end
          local function close_gitu_buffer(buf, win, did_split)
            if vim.api.nvim_buf_is_valid(buf) then
              if (did_split and vim.api.nvim_win_is_valid(win)) then
                local ok_3f = pcall(vim.api.nvim_win_close, win, true)
                if not ok_3f then
                  return delete_gitu_buffer(buf)
                else
                  return nil
                end
              else
                return delete_gitu_buffer(buf)
              end
            else
              return nil
            end
          end
          local function gitu()
            local running_buf = vim.iter(vim.api.nvim_list_bufs()):find(gitu_running_buffer_3f)
            if running_buf then
              return focus_gitu_buffer(running_buf)
            else
              local did_split = (normal_win_count() == 1)
              if did_split then
                split_for_gitu()
              else
              end
              vim.cmd("enew")
              local buf = vim.api.nvim_get_current_buf()
              local win = vim.api.nvim_get_current_win()
              vim.api.nvim_buf_set_var(buf, "gitu", true)
              vim.api.nvim_buf_set_var(buf, "gitu_running", true)
              vim.api.nvim_set_option_value("buflisted", false, {buf = buf})
              vim.api.nvim_set_option_value("bufhidden", "wipe", {buf = buf})
              local function _16_()
                return startinsert_if_current(buf)
              end
              vim.api.nvim_create_autocmd("BufEnter", {group = augroup, buffer = buf, callback = _16_})
              local job
              local function _17_()
                local function _18_(_, status, _0)
                  if vim.api.nvim_buf_is_valid(buf) then
                    vim.api.nvim_buf_set_var(buf, "gitu_running", false)
                  else
                  end
                  if (status == 0) then
                    local function _20_()
                      return close_gitu_buffer(buf, win, did_split)
                    end
                    return vim.schedule(_20_)
                  else
                    local function _21_()
                      return vim.notify(("gitu exited with code " .. status), vim.log.levels.WARN)
                    end
                    return vim.schedule(_21_)
                  end
                end
                return vim.fn.jobstart({"gitu"}, {term = true, on_exit = _18_})
              end
              job = with_editor_origin(win, buf, _17_)
              if (job <= 0) then
                vim.notify("failed to start gitu", vim.log.levels.ERROR)
                return delete_gitu_buffer(buf)
              else
                return vim.cmd("startinsert")
              end
            end
          end
          vim.api.nvim_create_user_command("Gitu", gitu, {})
          local function _25_()
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
              if gitu_buffer_3f(buf) then
                delete_gitu_buffer(buf)
              else
              end
            end
            return nil
          end
          return vim.api.nvim_create_user_command("GituClear", _25_, {})
        ''
      );
    }
    {
      plugin = vim-startuptime;
    }
    {
      plugin = translate-nvim;
      extraPackages = [ pkgs.curl ];
      config = luaConfig (
        # lua
        ''
          local translate = require("translate")
          local preset = {output = {floating = {zindex = 150}, split = {position = "bottom", min_size = 5, max_size = 0.5, name = "translate://output", filetype = "translate", append = false}}}
          local default = {output = "split"}
          return translate.setup({preset = preset, default = default})
        ''
      );
    }
    {
      plugin = menu;
      dependPlugins = [
        volt
      ];
      config = luaConfig (
        # lua
        ''
          local menu = require("menu")
          local separator = {name = "separator"}
          local default
          local function _1_()
            vim.o.list = not vim.o.list
            return nil
          end
          local function _2_()
            return vim.cmd("TimerlyToggle")
          end
          local function _3_()
            return vim.cmd("ShowkeysToggle")
          end
          local function _4_()
            return vim.cmd("Huefy")
          end
          default = {{hl = "Normal", name = "\239\136\132 Toggle NoNeckPain", cmd = "NoNeckPain"}, {hl = "Normal", name = "\239\136\132 Toggle List", cmd = _1_}, {hl = "Normal", name = "\239\136\132 Toggle colorize", cmd = "ColorizerToggle"}, {hl = "Normal", name = "\238\154\144 Edit local config", cmd = "ConfigLocalEdit"}, {hl = "Normal", name = "\243\176\158\183 Open scratch buffer", cmd = "RepluaOpen"}, separator, {hl = "Normal", name = "\243\176\132\137 Timer", cmd = _2_}, {hl = "Normal", name = "\239\132\156 Show keys", cmd = _3_}, {hl = "Normal", name = "\239\133\128 Color Picker", cmd = _4_}}
          local function _5_()
            return menu.open(default, {border = true})
          end
          return vim.api.nvim_create_user_command("OpenMenu", _5_, {})
        ''
      );
    }
    {
      plugin = minty;
      dependPlugins = [
        volt
      ];
    }
    {
      plugin = timerly;
      dependPlugins = [
        volt
      ];
      config = luaConfig (
        # lua
        ''
          local timerly = require("timerly")
          local api = require("timerly.api")
          local function _1_(buf)
            return vim.keymap.set("n", "<CR>", api.togglestatus, {buf = buf})
          end
          return timerly.setup({position = "top-right", mapping = _1_})
        ''
      );
    }
    {
      plugin = showkeys;
      dependPlugins = [
        volt
      ];
    }
    {
      plugin = NeoZoom-lua;
      config = luaConfig (
        # lua
        ''
          local zoom = require("neo-zoom")
          local winopts = {offset = {width = 180, height = 0.9}, border = "single"}
          local exclude_buftypes = {}
          local presets = {{filetypes = {"dapui_.*", "dap-repl"}, winopts = {offset = {top = 0.02, left = 0.26, width = 0.74, height = 0.6}}}}
          local callbacks
          local function _1_()
            for _, command in ipairs({"hi link NeoZoomFloatBg Normal", "hi link NeoZoomFloatBorder Normal", "set winhl=Normal:NeoZoomFloatBg,FloatBorder:NeoZoomFloatBorder"}) do
              vim.cmd(command)
            end
            return nil
          end
          callbacks = {_1_}
          return zoom.setup({winopts = winopts, exclude_buftypes = exclude_buftypes, presets = presets, callbacks = callbacks})
        ''
      );
    }
    {
      plugin = glance-nvim;
      dependPlugins = [
        trouble
      ];
      config = luaConfig (
        # lua
        ''
          local glance = require("glance")
          local border = {enable = true, top_char = "\226\148\129", bottom_char = "\226\148\129"}
          local folds = {fold_closed = "\226\150\184", fold_open = "\226\150\190", folded = true}
          return glance.setup({border = border, folds = folds, use_trouble_qf = true})
        ''
      );
    }
    {
      plugin = diffview-nvim;
      dependPlugins = [
        devicons
      ];
      config = luaConfig (
        # lua
        ''
          local diffview = require("diffview")
          return diffview.setup({icons = {folder_closed = "\238\151\191", folder_open = "\238\151\190"}, signs = {fold_closed = "\226\150\184", fold_open = "\226\150\190", done = "\226\156\147"}})
        ''
      );
    }
    {
      plugin = trace-pr-nvim;
      extraPackages = with pkgs; [ gh ];
      config = luaConfig (
        # lua
        ''
          local tp = require("trace-pr")
          return tp.setup({trace_by_commit_hash_when_pr_not_found = true})
        ''
      );
    }
    {
      plugin = oil-nvim;
      dependPlugins = [
        devicons
      ];
      config = luaConfig (
        # lua
        ''
          local M = require("oil")
          local function _1_(_name, _bufnr)
            return false
          end
          local function _2_(_name, _bufnr)
            return false
          end
          return M.setup({columns = {"icon", "permissions", "size", "mtime"}, delete_to_trash = true, lsp_file_methods = {timeout_ms = 5000}, view_options = {show_hidden = true, is_hidden_file = _1_, is_always_hidden = _2_, sort = {{"type", "asc"}, {"name", "asc"}}}, keymaps = {["g?"] = "actions.show_help", ["<CR>"] = "actions.select", e = "actions.select", ["<C-w>v"] = "actions.select_vsplit", ["<C-w>s"] = "actions.select_split", ["<C-t>"] = "actions.select_tab", ["<C-p>"] = "actions.preview", q = "actions.close", ["<C-c>"] = "actions.close", R = "actions.refresh", H = "actions.parent", L = "actions.select"}, keymaps_help = {border = "none"}, default_file_explorer = false, use_default_keymaps = false})
        ''
      );
    }
    {
      plugin = capture-vim;
    }
    {
      plugin = harpoon;
      dependPlugins = [ plenary ];
      config = luaConfig (
        # lua
        ''
          local harpoon = require("harpoon")
          local function display(item)
            local value = (item.value or "")
            local repo = vim.fn.fnamemodify(vim.uv.cwd(), ":t")
            local fname = vim.fn.fnamemodify(value, ":t")
            local dir = vim.fn.fnamemodify(value, ":h")
            if ((dir == ".") or (dir == "")) then
              return string.format("%s  %s", fname, repo)
            else
              return string.format("%s  %s/%s", fname, repo, dir)
            end
          end
          local function _2_()
            return vim.uv.cwd()
          end
          return harpoon.setup({settings = {key = _2_, save_on_toggle = false, sync_on_ui_close = false}, default = {display = display}})
        ''
      );
    }
    {
      plugin = detour-nvim;
    }
    {
      plugin = winshift-nvim;
      config = luaConfig (
        # lua
        ''
          local winshift = require("winshift")
          return winshift.setup({})
        ''
      );
    }
    {
      plugin = komado-nvim;
      dependPlugins = [
        worktab
      ];
      extraPackages = [ mimori ];
      preConfig = luaConfig (''
        package.preload["mimori.client"] = function() return dofile("${../support/mimori/client.lua}") end
        package.preload["mimori.labels"] = function() return dofile("${../support/mimori/labels.lua}") end
        package.preload["mimori.komado"] = function() return dofile("${../support/mimori/komado.lua}") end
        require("mimori.client").setup(vim.tbl_extend("force", {
          binary = "${mimori}/bin/mimori",
        }, vim.g.mimori or {}))
      '');
      config = luaConfig (
        # lua
        ''
          local komado = require("komado")
          local utils = require("komado.utils")
          local Line = require("komado.dsl").Line

          local Spacer = Line({ provider = "" })
          local Separator = utils.separator("─", "Comment")

          local function emitter(pattern)
            return function()
              pcall(vim.api.nvim_exec_autocmds, "User", {
                pattern = pattern,
                modeline = false,
              })
            end
          end

          -- 分境界に揃えて 60 秒ごとに KomadoTick を発火する。Clock / LoadAvg が共有する。
          local function periodic_tick()
            local timer = vim.uv.new_timer()
            if timer then
              timer:start((60 - tonumber(os.date("%S"))) * 1000, 60000, vim.schedule_wrap(emitter("KomadoTick")))
            end
          end

          local ASCII = {
            ["0"] = { "██████", "██  ██", "██  ██", "██  ██", "██████" },
            ["1"] = { "████  ", "  ██  ", "  ██  ", "  ██  ", "██████" },
            ["2"] = { "██████", "    ██", "██████", "██    ", "██████" },
            ["3"] = { "██████", "    ██", "██████", "    ██", "██████" },
            ["4"] = { "██  ██", "██  ██", "██████", "    ██", "    ██" },
            ["5"] = { "██████", "██    ", "██████", "    ██", "██████" },
            ["6"] = { "██████", "██    ", "██████", "██  ██", "██████" },
            ["7"] = { "██████", "    ██", "    ██", "    ██", "    ██" },
            ["8"] = { "██████", "██  ██", "██████", "██  ██", "██████" },
            ["9"] = { "██████", "██  ██", "██████", "    ██", "██████" },
            [":"] = { "  ", "██", "  ", "██", "  " },
            ["-"] = { "      ", "      ", "██████", "      ", "      " },
          }
          local function ascii_rows(text)
            local rows = { "", "", "", "", "" }
            for i = 1, #text do
              local glyph = ASCII[text:sub(i, i)]
              if glyph then
                local sep = (i > 1) and " " or ""
                for r = 1, 5 do
                  rows[r] = rows[r] .. sep .. glyph[r]
                end
              end
            end
            return rows
          end

          local Clock
          do
            periodic_tick()
            Clock = {
              update = { "User", pattern = "KomadoTick" },
              utils.mapped_list(function(_)
                return ascii_rows(os.date("%H:%M"))
              end, function(item)
                return utils.center(Line({ { provider = item, hl = "Comment" } }))
              end),
            }
          end

          local Footer
          do
            local v = vim.version()
            local Version = { provider = string.format(" %d.%d.%d", v.major, v.minor, v.patch) }

            local LoadAvg = {
              update = { "User", pattern = "KomadoTick" },
              {
                provider = function()
                  local one, five, fifteen = vim.uv.loadavg()
                  return string.format("%.2f %.2f %.2f", one, five, fifteen)
                end,
              },
            }

            Footer = { Version, utils.horizontal_align(), LoadAvg }
          end

          local CurrentTab
          do
            local worktab = require("worktab")
            local emit = emitter("KomadoTabChanged")
            vim.api.nvim_create_autocmd({ "TabEnter", "TabNewEntered", "TabClosed" }, { callback = emit })
            local function rename()
              vim.ui.input({ prompt = "tab name: ", default = worktab.get_name() or "" }, function(input)
                if input == nil then
                  return
                end
                worktab.set_name(input)
                emit()
              end)
            end
            CurrentTab = {
              update = { "User", pattern = "KomadoTabChanged" },
              Line({
                mappings = { i = rename },
                {
                  provider = function()
                    return string.format(" [%d] ", vim.fn.tabpagenr())
                  end,
                },
                {
                  provider = function()
                    return worktab.get_name() or "----"
                  end,
                  hl = { bold = true },
                },
              }),
            }
          end

          local GitStatus
          do
            local function git_start_dir()
              local name = vim.api.nvim_buf_get_name(0)
              if name ~= "" then
                local stat = vim.uv.fs_stat(name)
                if stat and stat.type == "directory" then
                  return name
                end
                return vim.fs.dirname(name)
              end
              return vim.fn.getcwd()
            end

            local function git_lines(root, args)
              local cmd = { "git", "-C", root }
              vim.list_extend(cmd, args)
              local lines = vim.fn.systemlist(cmd)
              if vim.v.shell_error ~= 0 then
                return nil
              end
              return lines
            end

            local function git_root()
              local lines = git_lines(git_start_dir(), { "rev-parse", "--show-toplevel" })
              return lines and lines[1] ~= "" and lines[1] or nil
            end

            local function git_status()
              local root = git_root()
              if not root then
                return nil
              end

              local lines = git_lines(root, { "status", "--short", "--branch", "--untracked-files=normal" }) or {}
              local status = {
                root = root,
                branch = "unknown",
                staged = {},
                unstaged = {},
                untracked = {},
              }

              for _, line in ipairs(lines) do
                if line:sub(1, 2) == "##" then
                  status.branch = line:sub(4)
                elseif line ~= "" then
                  local xy = line:sub(1, 2)
                  local x = xy:sub(1, 1)
                  local y = xy:sub(2, 2)
                  local path = line:sub(4)
                  if xy == "??" then
                    status.untracked[#status.untracked + 1] = { code = "?", path = path }
                  else
                    if x ~= " " then
                      status.staged[#status.staged + 1] = { code = x, path = path }
                    end
                    if y ~= " " then
                      status.unstaged[#status.unstaged + 1] = { code = y, path = path }
                    end
                  end
                end
              end

              return status
            end

            local function git_file_target(path)
              return path:match(".+ %-> (.+)$") or path
            end

            local function git_rows(status)
              local rows = {
                {
                  kind = "root",
                  branch = status and status.branch or "not a git repository",
                  clean = status and #status.staged == 0 and #status.unstaged == 0 and #status.untracked == 0,
                },
              }

              if not status then
                return rows
              end

              local sections = {
                { label = "Staged",    items = status.staged },
                { label = "Unstaged",  items = status.unstaged },
                { label = "Untracked", items = status.untracked },
              }

              for _, section in ipairs(sections) do
                if #section.items > 0 then
                  rows[#rows + 1] = {
                    kind = "section",
                    label = section.label,
                    count = #section.items,
                  }
                  for _, item in ipairs(section.items) do
                    rows[#rows + 1] = {
                      kind = "file",
                      root = status.root,
                      code = item.code,
                      path = item.path,
                    }
                  end
                end
              end

              if #rows == 1 and rows[1].clean then
                rows[#rows + 1] = { kind = "message", text = "  clean" }
              end
              return rows
            end

            local git_status_hl = {
              ["?"] = "Comment",
              A = "String",
              C = "Identifier",
              D = "ErrorMsg",
              M = "WarningMsg",
              R = "Identifier",
              U = "ErrorMsg",
            }

            GitStatus = {
              update = { "BufEnter", "BufWritePost", "DirChanged", "FocusGained", "ShellCmdPost" },
              init = function(self)
                self.status = git_status()
                self.rows = git_rows(self.status)
              end,
              utils.mapped_list(function(self)
                return self.rows
              end, function(item)
                if item.kind == "root" then
                  return Line({
                    { provider = "  ", hl = "Statement" },
                    { provider = item.branch, hl = item.clean and "String" or "Comment" },
                  })
                end

                if item.kind == "section" then
                  return Line({
                    { provider = "  ",                 hl = "Comment" },
                    { provider = item.label,           hl = "Identifier" },
                    { provider = " " },
                    { provider = tostring(item.count), hl = "Number" },
                  })
                end

                if item.kind == "file" then
                  local function open(_, ctx)
                    local selected = ctx.ctx.item
                    vim.cmd("wincmd p")
                    vim.cmd("edit " .. vim.fn.fnameescape(selected.root .. "/" .. git_file_target(selected.path)))
                  end
                  return Line({
                    mappings = {
                      ["<CR>"] = open,
                      ["<LeftMouse>"] = open,
                    },
                    { provider = "    " },
                    { provider = item.code, hl = git_status_hl[item.code] or "Comment" },
                    { provider = "  " },
                    { provider = item.path },
                  })
                end

                return Line({ provider = item.text, hl = "Comment" })
              end),
            }
          end

          local Pomodoro
          local pomodoro
          do
            local config = {
              work_ms = 25 * 60 * 1000,
              short_break_ms = 5 * 60 * 1000,
              long_break_ms = 15 * 60 * 1000,
              long_break_every = 4,
              tick_ms = 1000,
              auto_start_next = true,
              icons = {
                idle = "󰔛",
                work = "󰈸",
                short_break = "",
                long_break = "󰒲",
              },
            }

            local state = {
              phase = "idle",
              remaining_ms = 0,
              running = false,
              completed_work = 0,
            }

            local timer = vim.uv.new_timer()

            local emit_tick = emitter("PomodoroTick")

            -- 進捗バーは update=PomodoroTick でレンダリング結果がキャッシュされ、tick が発火するまで再評価されない。
            -- IDLE 中は tick が止まるため、サイドバー幅を変更してもバーが古い content_width のまま固定され表示幅が合わなくなる。
            -- リサイズ時に PomodoroTick を発火させてキャッシュを無効化し、現在の幅で描き直させる（Clock は KomadoTick 周期で追従するのと同等の役割）。
            vim.api.nvim_create_autocmd({ "VimResized", "WinResized" }, {
              group = vim.api.nvim_create_augroup("KomadoPomodoroResize", { clear = true }),
              callback = emit_tick,
            })

            local function format_remaining()
              if state.phase == "idle" then
                return "--:--"
              end
              local total_s = math.max(0, math.floor(state.remaining_ms / 1000))
              return string.format("%02d:%02d", math.floor(total_s / 60), total_s % 60)
            end

            local function display()
              local icon = config.icons[state.phase] or config.icons.idle
              return string.format("%s %s", icon, format_remaining())
            end

            local function duration_for(phase)
              if phase == "work" then
                return config.work_ms
              elseif phase == "short_break" then
                return config.short_break_ms
              elseif phase == "long_break" then
                return config.long_break_ms
              end
              return 0
            end

            local function compute_next_phase()
              if state.phase == "work" then
                if state.completed_work % config.long_break_every == 0 then
                  return "long_break"
                end
                return "short_break"
              end
              return "work"
            end

            local function notify_transition(to)
              local minutes = math.floor(duration_for(to) / 60000)
              local msg, level
              if to == "work" then
                msg = string.format("Pomodoro: back to work (%dm)", minutes)
                level = vim.log.levels.INFO
              elseif to == "short_break" then
                msg = string.format("Pomodoro: work finished — short break (%dm)", minutes)
                level = vim.log.levels.WARN
              elseif to == "long_break" then
                msg = string.format("Pomodoro: work finished — long break (%dm)", minutes)
                level = vim.log.levels.WARN
              end
              if msg then
                vim.notify(msg, level)
              end
            end

            local function advance_phase()
              if state.phase == "work" then
                state.completed_work = state.completed_work + 1
              end
              local nxt = compute_next_phase()
              notify_transition(nxt)
              state.phase = nxt
              state.remaining_ms = duration_for(nxt)
            end

            local function stop_timer()
              if timer and timer:is_active() then
                timer:stop()
              end
            end

            local function start_timer()
              if not timer then
                return
              end
              if timer:is_active() then
                timer:stop()
              end
              timer:start(
                config.tick_ms,
                config.tick_ms,
                vim.schedule_wrap(function()
                  if not state.running then
                    return
                  end
                  state.remaining_ms = state.remaining_ms - config.tick_ms
                  if state.remaining_ms <= 0 then
                    advance_phase()
                    if not config.auto_start_next then
                      state.running = false
                      stop_timer()
                    end
                  end
                  emit_tick()
                end)
              )
            end

            local function start()
              if state.phase == "idle" then
                state.phase = "work"
                state.remaining_ms = config.work_ms
                state.completed_work = 0
              end
              state.running = true
              start_timer()
              emit_tick()
            end

            local function stop()
              state.running = false
              state.phase = "idle"
              state.remaining_ms = 0
              state.completed_work = 0
              stop_timer()
              emit_tick()
            end

            local function pause()
              if not state.running then
                return
              end
              state.running = false
              stop_timer()
              emit_tick()
            end

            local function skip()
              if state.phase == "idle" then
                return
              end
              advance_phase()
              if state.running then
                start_timer()
              end
              emit_tick()
            end

            pomodoro = {
              state = state,
              config = config,
              start = start,
              stop = stop,
              pause = pause,
              skip = skip,
              reset = stop,
              display = display,
            }

            local function phase_label()
              local paused = state.phase ~= "idle" and not state.running
              local prefix
              if paused then
                prefix = "PAUSED"
              elseif state.phase == "work" then
                prefix = "WORK"
              elseif state.phase == "short_break" then
                prefix = "SHORT BREAK"
              elseif state.phase == "long_break" then
                prefix = "LONG BREAK"
              else
                prefix = "IDLE"
              end
              if state.phase == "work" and not paused then
                local total = config.long_break_every
                local current = (state.completed_work % total) + 1
                return string.format("%s (%d/%d)", prefix, current, total)
              end
              return prefix
            end

            local ModeLine = Line({
              provider = function()
                local icon = config.icons[state.phase] or config.icons.idle
                return icon .. " " .. phase_label()
              end,
            })

            local BLOCKS = { " ", "▏", "▎", "▍", "▌", "▋", "▊", "▉", "█" }
            local BAR_ROWS = 2

            local TRACK_DELTA = 24
            local function hl_attr(group, attr)
              local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
              return hl and hl[attr] or nil
            end
            -- 各チャンネルを delta だけ寄せる（dark は明るく / light は暗く する用途）
            local function shade(rgb, delta)
              local function clamp(x)
                return math.max(0, math.min(255, x))
              end
              local r = clamp(math.floor(rgb / 0x10000) % 0x100 + delta)
              local g = clamp(math.floor(rgb / 0x100) % 0x100 + delta)
              local b = clamp(rgb % 0x100 + delta)
              return r * 0x10000 + g * 0x100 + b
            end
            -- colorscheme 変更時だけ取り直してキャッシュする（描画ごとの nvim_get_hl を避ける）
            local fill_fg, track_bg
            local function refresh_colors()
              fill_fg = hl_attr("Comment", "fg")
              local normal_bg = hl_attr("Normal", "bg")
              if normal_bg then
                -- track は Normal.bg を基準に、light は少し暗く / dark は少し明るく
                local delta = (vim.o.background == "light") and -TRACK_DELTA or TRACK_DELTA
                track_bg = shade(normal_bg, delta)
              else
                track_bg = nil
              end
            end
            refresh_colors()
            vim.api.nvim_create_autocmd("ColorScheme", {
              group = vim.api.nvim_create_augroup("KomadoPomodoroColors", { clear = true }),
              callback = refresh_colors,
            })
            local function fill_hl()
              return { fg = fill_fg }
            end
            local function edge_hl()
              return { fg = fill_fg, bg = track_bg }
            end
            local function track_hl()
              return { bg = track_bg }
            end

            local function sidebar_width(self)
              local sb = self._sidebar
              local st = sb and sb._state
              return st and st._content_width or 0
            end

            local function progress_value()
              if state.phase == "idle" then
                return 1
              end
              local total_ms = duration_for(state.phase)
              if total_ms <= 0 then
                return 1
              end
              return math.max(0, math.min(1, state.remaining_ms / total_ms))
            end

            -- fill(残り) / edge(境界の部分ブロック) / track(消費分) のセル数を返す
            local function bar_parts(self)
              local width = sidebar_width(self)
              if width <= 0 then
                return 0, 0, 0
              end
              local total = math.floor(progress_value() * width * 8)
              local full = math.floor(total / 8)
              local partial = total % 8
              local has_edge = (partial > 0 and full < width)
              local track = width - full - (has_edge and 1 or 0)
              return full, (has_edge and partial or 0), math.max(0, track)
            end

            local function fill_provider(self)
              return string.rep("█", (bar_parts(self)))
            end

            local function edge_provider(self)
              local _, partial = bar_parts(self)
              return partial > 0 and BLOCKS[partial + 1] or ""
            end

            local function track_provider(self)
              local _, _, track = bar_parts(self)
              return string.rep(" ", track)
            end

            local ProgressIndicator = {}
            for _ = 1, BAR_ROWS do
              ProgressIndicator[#ProgressIndicator + 1] = Line({
                { provider = fill_provider,  hl = fill_hl },
                { provider = edge_provider,  hl = edge_hl },
                { provider = track_provider, hl = track_hl },
              })
            end

            Pomodoro = {
              update = { "User", pattern = "PomodoroTick" },
              ModeLine,
              ProgressIndicator,
            }
          end

          local MimoriStatus = require("mimori.komado").setup()

          komado.setup({
            window = { position = "left", size = { ratio = 0.2, min = 32, max = 40 }, padding = 1 },
            mappings = {
              q = function()
                komado.close()
              end,
              r = function()
                require("mimori.client").refresh()
                komado.redraw()
              end,
            },
            root = {
              CurrentTab,
              Separator,
              MimoriStatus,
              Separator,
              GitStatus,
              utils.vertical_align(),
              Pomodoro,
              Spacer,
              Clock,
              Spacer,
              Footer,
            },
          })

          vim.api.nvim_create_user_command("KomadoToggle", function()
            komado.toggle()
          end, {})
          vim.api.nvim_create_user_command("PomodoroStart", pomodoro.start, {})
          vim.api.nvim_create_user_command("PomodoroStop", pomodoro.stop, {})
          vim.api.nvim_create_user_command("PomodoroPause", pomodoro.pause, {})
          vim.api.nvim_create_user_command("PomodoroSkip", pomodoro.skip, {})
          vim.api.nvim_create_user_command("PomodoroReset", pomodoro.reset, {})
        ''
      );
    }
  ];
  doc = "Enabled v2/default commandPlugins configuration, loaded at startup. See the migration inventory in the core cartridge documentation.";
}
