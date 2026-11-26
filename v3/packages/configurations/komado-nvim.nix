{
  pkgs,
  lib,
  sources,
  definitions,
  luaConfig,
  luaCheck,
  inputs',
}:
with sources;
let
  mimori = inputs'.v3-mimori.packages.default;
in
{
  plugin = sources.komado-nvim;
  lazy = true;
  onCommands = [
    "KomadoToggle"
    "KomadoTimeline"
    "MimoriAll"
    "MimoriRefresh"
    "MimoriStatus"
    "PomodoroStart"
    "PomodoroStop"
    "PomodoroPause"
    "PomodoroSkip"
    "PomodoroReset"
  ];
  onModules = [
    "komado"
    "mimori"
  ];
  doc = ''
    # komado.nvim

    ## 概要
    Lua のコンポーネントツリーで内容と操作を定義する Neovim のサイドバー。

    ## 主な機能
    - テキスト・ハイライト・行アクションの宣言的な組み立て。
    - イベントによる更新とタブ間で共有するサイドバー。

    ## 使い方
    `require("komado").setup({ root = ... })` で内容を定義し、`open()`・`close()`・`toggle()`・`redraw()` で操作する。README のキーマップやコマンドは設定例であり、標準では登録されない。

    `:KomadoTimeline [project-id]` selects a Track project from the configured vault (`~/track/`). In the sidebar, `t` selects a project, `K` previews the current Timeline row, and `r` refreshes. Tasks and recent updates are always shown for the selected project, with timestamps in the local time zone. Updates run every five seconds only while the sidebar is open. No project is created or changed automatically.

    ## 要件
    This configuration uses Track and its bundled CLI. README の上流回帰テスト対象は Neovim 0.11.4・0.12.5・0.12.6 で、それより古い版の互換性は未確認。

    ## 出典
    - [上流 README（固定リビジョン）](https://github.com/ttak0422/komado.nvim/blob/5f392f172f28b5212899b19877ce74e2a85fda7e/README.md)
  '';
  dependPlugins = [
    definitions.track
    definitions.worktab-nvim
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

      local function sidebar_width(self)
        local sb = self._sidebar
        local st = sb and sb._state
        return st and st._content_width or 0
      end

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

      local timeline_model = require("track.agent_timeline")
      local timeline_render = dofile("${../support/track-timeline.lua}")
      local timeline, timeline_open, timeline_buffer = nil, false, nil
      local timeline_options = { vault_dir = require("track.config").options.vault_dir }

      local function refresh_timeline()
        if timeline and timeline_open then timeline.refresh() end
      end

      local timeline_heading = "Timeline  [t:select K:detail]"
      local timeline_update = emitter("TrackTimelineChanged")
      local function focus_timeline()
        local state = komado.open({ focus = true })
        if not state.winid or not vim.api.nvim_win_is_valid(state.winid) then return end
        vim.api.nvim_set_current_win(state.winid)
        for index, line in ipairs(vim.api.nvim_buf_get_lines(state.bufnr, 0, -1, false)) do
          if vim.startswith(vim.trim(line), "Timeline  [") then
            vim.api.nvim_win_set_cursor(state.winid, { index, 0 })
            break
          end
        end
      end

      local function select_timeline(id, focus)
        if not id or id == "" then
          timeline_model.list(timeline_options, function(err, data)
            if err then vim.notify(err, vim.log.levels.ERROR); return end
            if #data.projects == 0 then
              vim.notify("No timeline projects. Create one with :Track timeline.")
              return
            end
            vim.ui.select(data.projects, {
              prompt = "Sidebar timeline",
              format_item = function(project) return project.title .. " (" .. project.project_id .. ")" end,
            }, function(project)
              if project then select_timeline(project.project_id, focus) end
            end)
          end)
          return
        end
        local ok, next_view = pcall(timeline_model.new, id, timeline_options)
        if not ok then vim.notify(tostring(next_view), vim.log.levels.ERROR); return end
        if timeline then timeline.dispose() end
        timeline = next_view
        timeline_update()
        if focus then focus_timeline() else komado.open() end
        refresh_timeline()
        timeline.watch(5000)
      end

      local Timeline = {
        -- Don't freeze this subtree: Komado also redraws it on resize.
        Line({ provider = function(self)
          return timeline_render.fit(timeline_heading, sidebar_width(self))
        end, hl = "Title" }),
        utils.mapped_list(function(self)
          local width = sidebar_width(self)
          if not timeline then
            return { { text = timeline_render.fit("Select a timeline with t", width) } }
          end
          return timeline_render.rows(timeline, width)
        end, function(row)
          return Line({
            mappings = row.detail and { K = function() timeline_render.preview(row.detail) end } or nil,
            { provider = row.prefix or "" },
            { provider = row.icon or "", hl = row.hl },
            { provider = row.text },
          })
        end),
      }

      local timeline_group = vim.api.nvim_create_augroup("DotfilesKomadoTimeline", { clear = true })
      vim.api.nvim_create_autocmd("User", {
        group = timeline_group, pattern = "TrackTimelineChanged",
        callback = function()
          if timeline_open then vim.schedule(komado.redraw) end
        end,
      })
      vim.api.nvim_create_autocmd("User", {
        group = timeline_group, pattern = "KomadoWindowAfterOpen",
        callback = function(event)
          timeline_buffer = event.data.bufnr
          timeline_open = true
          if timeline then refresh_timeline(); timeline.watch(5000) end
        end,
      })
      vim.api.nvim_create_autocmd("User", {
        group = timeline_group, pattern = "KomadoWindowAfterClose",
        callback = function()
          timeline_open, timeline_buffer = false, nil
          if timeline then timeline.dispose() end
        end,
      })
      -- Native :close/:only bypass Komado's close event. Defer visibility checks
      -- until tab switches finish their temporary detach/reattach cycle.
      local visibility_pending = false
      vim.api.nvim_create_autocmd({ "WinClosed", "BufWinEnter", "TabEnter" }, {
        group = timeline_group,
        callback = function()
          if visibility_pending then return end
          visibility_pending = true
          vim.schedule(function()
            visibility_pending = false
            local visible = timeline_buffer ~= nil
              and vim.api.nvim_buf_is_valid(timeline_buffer)
              and #vim.fn.win_findbuf(timeline_buffer) > 0
            if visible == timeline_open then return end
            timeline_open = visible
            if not timeline then return end
            if visible then
              refresh_timeline()
              timeline.watch(5000)
            else
              timeline.dispose()
            end
          end)
        end,
      })
      vim.api.nvim_create_autocmd("VimLeavePre", {
        group = timeline_group,
        callback = function() if timeline then timeline.dispose() end end,
      })
      vim.api.nvim_create_user_command("KomadoTimeline", function(opts)
        select_timeline(opts.args)
      end, { nargs = "?", desc = "Select a Track project for the sidebar" })

      local MimoriStatus = require("mimori.komado").setup()

      komado.setup({
        window = { position = "left", size = { ratio = 0.2, min = 32, max = 40 }, padding = 1 },
        mappings = {
          q = function()
            komado.close()
          end,
          t = function() select_timeline(nil, true) end,
          r = function()
            refresh_timeline()
            require("mimori.client").refresh()
            komado.redraw()
          end,
        },
        root = {
          CurrentTab,
          Separator,
          MimoriStatus,
          Separator,
          Timeline,
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
  tests.komado-timeline-lifecycle = luaCheck {
    name = "komado-timeline-lifecycle";
    preInit = ''
      _G.timeline_test = { views = {}, lists = 0 }
      package.preload["track.agent_timeline"] = function()
        return {
          list = function(_, callback)
            timeline_test.lists = timeline_test.lists + 1
            callback(nil, { projects = { { project_id = "fixture", title = "Fixture" } } })
          end,
          new = function(id, options)
            assert(options.vault_dir == os.getenv("HOME") .. "/track/")
            local view = { project_id = id, reads = 0, watches = 0, disposals = 0 }
            view.refresh = function()
              view.reads = view.reads + 1
              vim.schedule(function()
                view.snapshot = {
                  title = "Fixture", revision = 7, progress = { fraction = 0.5, remaining_minutes = 12 },
                  tasks = {
                    { id = "task-a", title = "Task fixture", status = "active", owner = "codex",
                      priority = 1, weight = 2, mode = "serial", done_minutes = 3,
                      remaining_minutes = 12, detail = "詳細" .. string.rep("検", 55) },
                    { id = "task-b", title = "長いタイトル" .. string.rep("続", 26), status = "pending" },
                  },
                  task_progress = { ["task-a"] = { fraction = 0.25 } },
                  reports = { { id = "report-a", author = "codex", summary = "Report fixture",
                    event_sequences = { 1, 2 }, period_start = "2026-11-23T14:00:00Z", period_end = "2026-11-23T14:15:00Z",
                    uncertainty = "Review fixture", user_action = "Reply fixture" } },
                  discussions = { { author = "user", target_type = "task", target_id = "task-a", text = "Discussion fixture" } },
                  controls = { { id = "ctrl-a", action = "pause", owner = "codex",
                    status = "acknowledged", result = "Receipt fixture" } },
                  events = {
                    { sequence = 2, at = "2026-11-23T14:00:00Z", kind = "task.upsert", source = "nvim",
                      event_id = "event-a", payload = { id = "task-a", title = "Task fixture", status = "pending" } },
                    { sequence = 3, at = "2026-11-23T14:01:00Z", kind = "task.upsert", source = "nvim",
                      event_id = "event-b", payload = { id = "task-a", title = "Task fixture", status = "active" } },
                    { sequence = 4, at = "2026-11-23T14:15:00Z", kind = "report.add", source = "codex",
                      event_id = "event-c", payload = { summary = "Report fixture" } },
                  },
                }
                vim.api.nvim_exec_autocmds("User", { pattern = "TrackTimelineChanged", modeline = false })
              end)
            end
            view.watch = function(interval)
              assert(interval == 5000)
              view.watches = view.watches + 1
            end
            view.dispose = function() view.disposals = view.disposals + 1 end
            table.insert(timeline_test.views, view)
            return view
          end,
        }
      end
    '';
    script = ''
      vim.cmd("KomadoToggle")
      local lines = vim.api.nvim_buf_get_lines(require("komado.state").get().bufnr, 0, -1, false)
      local positions = {}
      for index, line in ipairs(lines) do
        for _, label in ipairs({ "Claude", "Codex", "Timeline", "" }) do
          if not positions[label] and line:find(label, 1, true) then positions[label] = index end
        end
      end
      assert(positions.Claude and positions.Codex and positions.Timeline and positions[""],
        "sidebar must render agent, timeline and Git sections")
      assert(positions.Claude < positions.Codex and positions.Codex < positions.Timeline
        and positions.Timeline < positions[""], "sidebar sections must follow Claude, Codex, Timeline, Git")
      assert(#timeline_test.views == 0, "opening must not choose or create a project")
      local select = vim.ui.select
      vim.ui.select = function(items, _, callback) callback(items[1]) end
      local sidebar = require("komado.state").get()
      local sidebar_win, sidebar_buf = sidebar.winid, sidebar.bufnr
      local function split_windows()
        return vim.tbl_filter(function(win)
          local config = vim.api.nvim_win_get_config(win)
          return config.relative == "" and not config.external
        end, vim.api.nvim_list_wins())
      end
      local windows = split_windows()
      vim.api.nvim_set_current_win(sidebar_win)
      local function open_inline()
        vim.api.nvim_win_set_cursor(sidebar_win, { 1, 0 })
        vim.api.nvim_feedkeys("t", "mx", false)
        assert(vim.deep_equal(split_windows(), windows), "Timeline must not open another split")
        assert(vim.api.nvim_get_current_win() == sidebar_win
          and vim.api.nvim_get_current_buf() == sidebar_buf, "Timeline must stay inside Komado")
        assert(vim.trim(vim.api.nvim_get_current_line()) == "Timeline  [t:select K:detail]",
          "Open must focus the Timeline section")
      end
      open_inline()
      vim.ui.select = select
      local first = timeline_test.views[1]
      assert(timeline_test.lists == 1 and first.project_id == "fixture")
      assert(first.reads > 0 and first.watches > 0)
      local function rendered()
        return table.concat(vim.api.nvim_buf_get_lines(sidebar_buf, 0, -1, false), "\n")
      end
      local report_time = os.date("%H:%M", 1795443300) -- 2026-11-23 14:15 UTC
      local start_time = os.date("%H:%M", 1795442460)
      assert(vim.wait(1000, function() return rendered():find(report_time .. "  Report fixture", 1, true) end),
        "Timeline overview must render in the Komado buffer")
      local detail = rendered()
      for _, wanted in ipairs({ "50%", "━━", "──", "● Task fixture", "最近の更新", start_time .. "  開始: Task fixture" }) do
        assert(detail:find(wanted, 1, true), "Missing Timeline overview: " .. wanted)
      end
      assert(detail:find(report_time .. "  Report", 1, true) < detail:find(start_time .. "  開始", 1, true),
        "Show newest update first")
      assert(vim.fn.maparg("T", "n", false, true).buffer ~= 1, "No sidebar detail toggle")
      for _, hidden in ipairs({ "Revision 7", "ID: task-a", "event-a", "Recorded events", "Payload:",
        "Discussion fixture", "Receipt fixture", "詳細", "Review fixture" }) do
        assert(not detail:find(hidden, 1, true), "Leaked Timeline detail: " .. hidden)
      end
      local function find_line(needle)
        for index, line in ipairs(vim.api.nvim_buf_get_lines(sidebar_buf, 0, -1, false)) do
          if line:find(needle, 1, true) then return index, line end
        end
      end
      local task_row, task_line = find_line("○ 長いタイトル")
      assert(task_row and task_line:find("…", 1, true))
      assert(vim.wo[sidebar_win].wrap == false)
      assert(find_line("最近の更新") == task_row + 2, "Each task occupies one buffer row")
      local function has_icon_hl(row, icon)
        local icon_start = assert(vim.api.nvim_buf_get_lines(sidebar_buf, row - 1, row, false)[1]:find(icon, 1, true))
        for _, mark in ipairs(vim.api.nvim_buf_get_extmarks(sidebar_buf, -1, { row - 1, 0 }, { row - 1, -1 },
          { details = true })) do
          if mark[3] == icon_start - 1 and mark[4].end_col == icon_start - 1 + #icon then return true end
        end
      end
      assert(has_icon_hl(task_row, "○") and has_icon_hl(find_line("● Task fixture"), "●"),
        "Status highlight must cover the icon only")

      local function preview(needle, wanted, width)
        vim.api.nvim_win_set_cursor(sidebar_win, { find_line(needle), 0 })
        vim.api.nvim_feedkeys("K", "mx", false)
        local float = vim.b[sidebar_buf].lsp_floating_preview
        assert(float and vim.api.nvim_win_is_valid(float), "K did not open row detail")
        local cfg = vim.api.nvim_win_get_config(float)
        assert(cfg.relative ~= "" and cfg.relative ~= "editor" and cfg.win == sidebar_win,
          "Detail must be positioned relative to the sidebar cursor")
        if width then
          assert(cfg.width == width, ("Expected preview width %d, got %d"):format(width, cfg.width))
          assert(vim.wo[float].wrap and cfg.height >= 2, "Long detail must wrap in the preview")
        end
        local lines = vim.api.nvim_buf_get_lines(vim.api.nvim_win_get_buf(float), 0, -1, false)
        assert(table.concat(lines, "\n"):find(wanted, 1, true))
        assert(vim.api.nvim_get_current_win() == sidebar_win and vim.deep_equal(split_windows(), windows))
        vim.api.nvim_win_close(float, true)
      end
      preview("○ 長いタイトル", "長いタイトル" .. string.rep("続", 26))
      preview("● Task fixture", "詳細" .. string.rep("検", 55), math.min(80, vim.o.columns - 2))
      preview("Report fixture", report_time .. "  Report fixture")

      local _, before_bar = find_line("━━")
      vim.api.nvim_win_set_width(sidebar_win, vim.api.nvim_win_get_width(sidebar_win) + 8)
      -- The check runs in one Lua RPC call, before the UI loop emits WinResized.
      vim.api.nvim_exec_autocmds("WinResized", {})
      assert(vim.wait(1000, function()
        local _, bar = find_line("━━")
        return vim.fn.strdisplaywidth(bar) > vim.fn.strdisplaywidth(before_bar)
      end), "Progress bar must follow Komado resize")
      local _, wider_task = find_line("○ 長いタイトル")
      assert(#wider_task > #task_line, "Text truncation must also follow Komado resize")
      local _, wider_bar = find_line("━━")
      assert(vim.fn.strdisplaywidth(wider_bar) == vim.api.nvim_win_get_width(sidebar_win) - 1,
        "Progress bar must use the padded content width")
      local komado = require("komado")
      local reads = first.reads
      komado.redraw()
      komado.redraw()
      assert(first.reads == reads, "render providers must only read cached rows")
      komado.close()
      assert(first.disposals > 0, "closing must stop polling and cancel reads")
      local watches = first.watches
      komado.open()
      assert(first.watches > watches and first.reads > reads, "reopening must resume updates")
      local disposals = first.disposals
      vim.cmd("KomadoTimeline other")
      assert(first.disposals > disposals, "selection must dispose the previous view")
      assert(timeline_test.views[2].project_id == "other")
      komado.close()
      assert(timeline_test.views[2].disposals > 0)

      for _, close in ipairs({
        function() vim.cmd("close") end,
        function() vim.cmd("wincmd c") end,
        function()
          vim.cmd("wincmd p")
          vim.cmd("only")
        end,
      }) do
        vim.cmd("KomadoTimeline native-close")
        local view = timeline_test.views[#timeline_test.views]
        vim.api.nvim_set_current_win(require("komado.state").get().winid)
        close()
        assert(vim.wait(1000, function() return view.disposals > 0 end),
          "native window closing must dispose polling and in-flight reads")
        local reads = view.reads
        komado.redraw()
        assert(view.reads == reads, "hidden redraw must not resume reads")
        komado.open()
        assert(view.reads > reads, "opening after native close must resume reads")
        local disposals, watches = view.disposals, view.watches
        vim.cmd("tabnew")
        vim.wait(50, function() return false end)
        assert(view.disposals == disposals and view.watches == watches,
          "temporary tab detach/reattach must preserve the watcher")
        vim.cmd("tabclose")
        vim.wait(50, function() return false end)
        assert(view.disposals == disposals, "returning tabs must preserve the watcher")
        komado.close()
      end
    '';
  };
}
