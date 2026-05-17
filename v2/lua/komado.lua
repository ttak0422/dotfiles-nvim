local komado = require("komado")
local utils = require("komado.utils")
local Line = require("komado.dsl").Line

local Spacer = Line({ provider = "" })
local Separator = utils.separator("─", "Comment")

local Header
do
	local Name = { provider = " Neovim " }
	local v = vim.version()
	local Version = { provider = string.format("v%d.%d.%d", v.major, v.minor, v.patch) }
	Header = { Line({ Name, utils.horizontal_align(), Version }) }
end

local LoadAvg
do
	local WIDTH = 30
	local HEIGHT = 4
	local PIXEL_W = WIDTH * 2
	local PIXEL_H = HEIGHT * 4

	local SERIES_HL = {
		{ fg = "#61afef" }, -- 1min
		{ fg = "#e5c07b" }, -- 5min
		{ fg = "#98c379" }, -- 15min
	}
	local LABEL = "─ LOAD "
	local TAIL = " " .. string.rep("─", WIDTH - 22)

	-- Braille bit per (sub_col, sub_row) within a 2x4 cell.
	local BIT = {
		[0] = { [0] = 0x01, [1] = 0x02, [2] = 0x04, [3] = 0x40 },
		[1] = { [0] = 0x08, [1] = 0x10, [2] = 0x20, [3] = 0x80 },
	}
	local bor = bit.bor

	local hist = { {}, {}, {} }

	local function sample()
		local l1, l5, l15 = vim.uv.loadavg()
		local cur = { l1, l5, l15 }
		for i = 1, 3 do
			hist[i][#hist[i] + 1] = cur[i]
			if #hist[i] > PIXEL_W then
				table.remove(hist[i], 1)
			end
		end
	end

	local function y_range()
		local mn, mx = math.huge, -math.huge
		for i = 1, 3 do
			for _, v in ipairs(hist[i]) do
				if v < mn then
					mn = v
				end
				if v > mx then
					mx = v
				end
			end
		end
		if mn == math.huge then
			return 0, 1
		end
		if mx - mn < 1e-6 then
			mx = mn + 1e-6
		end
		return mn, mx
	end

	local function build_grid()
		local mn, mx = y_range()
		local span = mx - mn
		local bits, owner = {}, {}
		for r = 0, HEIGHT - 1 do
			bits[r] = {}
			owner[r] = {}
			for c = 0, WIDTH - 1 do
				bits[r][c] = 0
			end
		end
		-- Lower priority first so higher overwrites owner.
		for _, idx in ipairs({ 3, 2, 1 }) do
			local s = hist[idx]
			local n = #s
			for i, v in ipairs(s) do
				local x = (i - 1) + (PIXEL_W - n) -- right-align latest sample
				local cc = math.floor(x / 2)
				local sc = x % 2
				local yp = math.floor((1 - (v - mn) / span) * (PIXEL_H - 1))
				if yp < 0 then
					yp = 0
				end
				if yp > PIXEL_H - 1 then
					yp = PIXEL_H - 1
				end
				local cr = math.floor(yp / 4)
				local sr = yp % 4
				bits[cr][cc] = bor(bits[cr][cc], BIT[sc][sr])
				owner[cr][cc] = idx
			end
		end
		return bits, owner
	end

	local function row_segments(bits, owner, r)
		local segs, cur_hl, cur_text = {}, nil, ""
		for c = 0, WIDTH - 1 do
			local b = bits[r][c]
			local ch = (b == 0) and " " or vim.fn.nr2char(0x2800 + b)
			local hl = owner[r][c] and SERIES_HL[owner[r][c]] or nil
			if hl ~= cur_hl then
				if cur_text ~= "" then
					segs[#segs + 1] = { provider = cur_text, hl = cur_hl }
				end
				cur_hl = hl
				cur_text = ch
			else
				cur_text = cur_text .. ch
			end
		end
		if cur_text ~= "" then
			segs[#segs + 1] = { provider = cur_text, hl = cur_hl }
		end
		return segs
	end

	local sample_timer = vim.uv.new_timer()
	if sample_timer then
		sample_timer:start(
			0,
			60000,
			vim.schedule_wrap(function()
				sample()
				pcall(vim.api.nvim_exec_autocmds, "User", {
					pattern = "KomadoLoadAvgTick",
					modeline = false,
				})
			end)
		)
	end

	local function fmt(idx)
		return function()
			local v = { vim.uv.loadavg() }
			return string.format("%.2f", v[idx])
		end
	end

	LoadAvg = {
		update = { "User", pattern = "KomadoLoadAvgTick" },
		Line({
			{ provider = LABEL,  hl = "Comment" },
			{ provider = fmt(1), hl = SERIES_HL[1] },
			{ provider = " " },
			{ provider = fmt(2), hl = SERIES_HL[2] },
			{ provider = " " },
			{ provider = fmt(3), hl = SERIES_HL[3] },
			{ provider = TAIL,   hl = "Comment" },
		}),
		utils.mapped_list(function()
			local bits, owner = build_grid()
			local rows = {}
			for r = 0, HEIGHT - 1 do
				rows[r + 1] = row_segments(bits, owner, r)
			end
			return rows
		end, function(segs)
			return Line(segs)
		end),
	}
end

local Footer
do
	local clock_timer = vim.uv.new_timer()
	if clock_timer then
		clock_timer:start(
			(60 - tonumber(os.date("%S"))) * 1000,
			60000,
			vim.schedule_wrap(function()
				pcall(vim.api.nvim_exec_autocmds, "User", {
					pattern = "KomadoTick",
					modeline = false,
				})
			end)
		)
	end
	local Clock = {
		update = { "User", pattern = "KomadoTick" },
		{
			provider = function()
				return os.date("%Y-%m-%d %H:%M ")
			end,
			hl = "Comment",
		},
	}

	Footer = { utils.center(Line({ Clock })) }
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

	local function emit_tick()
		pcall(vim.api.nvim_exec_autocmds, "User", {
			pattern = "PomodoroTick",
			modeline = false,
		})
	end

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
					if state.phase == "work" then
						state.completed_work = state.completed_work + 1
					end
					local nxt = compute_next_phase()
					notify_transition(nxt)
					state.phase = nxt
					state.remaining_ms = duration_for(nxt)
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
		if state.phase == "work" then
			state.completed_work = state.completed_work + 1
		end
		local nxt = compute_next_phase()
		notify_transition(nxt)
		state.phase = nxt
		state.remaining_ms = duration_for(nxt)
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

	local ASCII = {
		["0"] = {
			"██████",
			"██  ██",
			"██  ██",
			"██  ██",
			"██████",
		},
		["1"] = {
			"████  ",
			"  ██  ",
			"  ██  ",
			"  ██  ",
			"██████",
		},
		["2"] = {
			"██████",
			"    ██",
			"██████",
			"██    ",
			"██████",
		},
		["3"] = {
			"██████",
			"    ██",
			"██████",
			"    ██",
			"██████",
		},
		["4"] = {
			"██  ██",
			"██  ██",
			"██████",
			"    ██",
			"    ██",
		},
		["5"] = {
			"██████",
			"██    ",
			"██████",
			"    ██",
			"██████",
		},
		["6"] = {
			"██████",
			"██    ",
			"██████",
			"██  ██",
			"██████",
		},
		["7"] = {
			"██████",
			"    ██",
			"    ██",
			"    ██",
			"    ██",
		},
		["8"] = {
			"██████",
			"██  ██",
			"██████",
			"██  ██",
			"██████",
		},
		["9"] = {
			"██████",
			"██  ██",
			"██████",
			"    ██",
			"██████",
		},
		[":"] = {
			"  ",
			"██",
			"  ",
			"██",
			"  ",
		},
		["-"] = {
			"      ",
			"      ",
			"██████",
			"      ",
			"      ",
		},
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
			local segments = {}
			for i = 1, total do
				segments[i] = (i <= current) and "█████" or "|||||"
			end
			return prefix .. " " .. table.concat(segments, " ")
		end
		return prefix
	end

	local ModeLine = Line({
		provider = function()
			local icon = config.icons[state.phase] or config.icons.idle
			return icon .. " " .. phase_label()
		end,
	})

	local AsciiTimer = utils.mapped_list(function(_)
		return ascii_rows(format_remaining())
	end, function(item)
		return Line({ { provider = item } })
	end)

	Pomodoro = {
		update = { "User", pattern = "PomodoroTick" },
		ModeLine,
		Spacer,
		AsciiTimer,
	}
end

local ClaudeStatus
do
	local state_dir = (vim.env.XDG_STATE_HOME or (vim.env.HOME .. "/.local/state")) .. "/komado/claude"
	local STALE_SEC = 60 * 30
	local DONE_GRACE_SEC = 5
	local CLEANUP_SEC = 60 * 60 * 24

	local LOGO_HL = { fg = "#D97757" }
	local LOGO_ROWS = {
		" ▐▛███▜▌ ",
		"▝▜█████▛▘",
		"  ▘▘ ▝▝  ",
	}

	local function dir_exists()
		return vim.uv.fs_stat(state_dir) ~= nil
	end

	local function read_json(path)
		local fd = vim.uv.fs_open(path, "r", 438)
		if not fd then
			return nil
		end
		local stat = vim.uv.fs_fstat(fd)
		if not stat then
			vim.uv.fs_close(fd)
			return nil
		end
		local data = vim.uv.fs_read(fd, stat.size, 0)
		vim.uv.fs_close(fd)
		if not data then
			return nil
		end
		local ok, obj = pcall(vim.json.decode, data)
		return ok and obj or nil
	end

	if dir_exists() then
		local now = os.time()
		local h = vim.uv.fs_scandir(state_dir)
		if h then
			while true do
				local name = vim.uv.fs_scandir_next(h)
				if not name then
					break
				end
				if name:match("%.json$") then
					local path = state_dir .. "/" .. name
					local st = vim.uv.fs_stat(path)
					if st and (now - st.mtime.sec) > CLEANUP_SEC then
						vim.uv.fs_unlink(path)
					end
				end
			end
		end
	end

	local sessions = {}

	local function reload()
		local rows, now = {}, os.time()
		local h = vim.uv.fs_scandir(state_dir)
		if h then
			while true do
				local name = vim.uv.fs_scandir_next(h)
				if not name then
					break
				end
				if name:match("%.json$") then
					local obj = read_json(state_dir .. "/" .. name)
					if obj then
						local age = now - (obj.last_event_at or 0)
						obj._stale = age > STALE_SEC
						if obj.status == "done" and age > DONE_GRACE_SEC then
							obj._display_status = "idle"
						else
							obj._display_status = obj.status
						end
						rows[#rows + 1] = obj
					end
				end
			end
		end
		table.sort(rows, function(a, b)
			return (a.started_at or 0) < (b.started_at or 0)
		end)
		sessions = rows
	end

	local function emit()
		pcall(vim.api.nvim_exec_autocmds, "User", {
			pattern = "KomadoClaudeTick",
			modeline = false,
		})
	end

	local fs_evt = vim.uv.new_fs_event()
	local debounce = vim.uv.new_timer()
	if fs_evt and debounce and dir_exists() then
		fs_evt:start(
			state_dir,
			{},
			vim.schedule_wrap(function()
				debounce:stop()
				debounce:start(150, 0, vim.schedule_wrap(emit))
			end)
		)
	end

	vim.api.nvim_create_autocmd({ "DirChanged", "FocusGained" }, { callback = emit })

	local stale_timer = vim.uv.new_timer()
	if stale_timer then
		stale_timer:start(60000, 60000, vim.schedule_wrap(emit))
	end

	local icons = {
		idle = "󰇘",
		running = "",
		waiting = "󰇘",
		done = "󰄬",
		stale = "",
	}

	ClaudeStatus = {
		condition = dir_exists,
		update = { "User", pattern = "KomadoClaudeTick" },
		init = function(_)
			reload()
		end,
		Line({ provider = LOGO_ROWS[1], hl = LOGO_HL }),
		Line({ provider = LOGO_ROWS[2], hl = LOGO_HL }),
		Line({ provider = LOGO_ROWS[3], hl = LOGO_HL }),
		utils.mapped_list(function()
			if #sessions == 0 then
				return { { kind = "empty" } }
			end
			local rows = {}
			for _, s in ipairs(sessions) do
				rows[#rows + 1] = { kind = "head", session = s }
				rows[#rows + 1] = { kind = "summary", session = s }
			end
			return rows
		end, function(item)
			if item.kind == "empty" then
				return Line({ provider = "no sessions", hl = "Comment" })
			end
			if item.kind == "head" then
				local s = item.session._stale and "stale" or item.session._display_status
				local name = (item.session.name and item.session.name ~= "") and item.session.name or "?"
				local last_tool = item.session.last_tool and ("  " .. item.session.last_tool) or ""
				return Line({
					{ provider = icons[s] or "?" },
					{ provider = " " },
					{ provider = name },
					{ provider = last_tool,      hl = "Comment" },
				})
			end
			local summary = item.session.prompt_summary
			local text = (summary and summary ~= "") and summary:gsub("[%c]", " ") or "----"
			return Line({
				{ provider = "  " },
				{ provider = text, hl = "Comment" },
			})
		end),
	}

	vim.api.nvim_create_user_command("KomadoClaudeClean", function()
		local h = vim.uv.fs_scandir(state_dir)
		local n = 0
		if h then
			while true do
				local name = vim.uv.fs_scandir_next(h)
				if not name then
					break
				end
				if name:match("%.json$") then
					vim.uv.fs_unlink(state_dir .. "/" .. name)
					n = n + 1
				end
			end
		end
		vim.notify(string.format("KomadoClaudeClean: removed %d file(s)", n))
		emit()
	end, {})
end

komado.setup({
	window = { position = "left", size = { ratio = 0.2, min = 32, max = 40 }, padding = 1 },
	mappings = {
		q = function()
			komado.close()
		end,
		r = function()
			komado.redraw()
		end,
	},
	root = {
		Header,
		Spacer,
		ClaudeStatus,
		Separator,
		GitStatus,
		utils.vertical_align(),
		Pomodoro,
		Spacer,
		LoadAvg,
		Separator,
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
