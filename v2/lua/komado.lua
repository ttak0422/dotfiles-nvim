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
	Header = { Line({ Name,
		utils.horizontal_align(), Version }) }
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

	local icon_start = "󰐊"
	local icon_pause = "󰏤"
	local icon_reset = "󰜉"

	local ModeLine = utils.center(Line({
		provider = function()
			local icon = config.icons[state.phase] or config.icons.idle
			return icon .. " " .. phase_label()
		end,
	}))

	local AsciiTimer = utils.mapped_list(function(_)
		return ascii_rows(format_remaining())
	end, function(item)
		return utils.center(Line({ { provider = item } }))
	end)

	local function on_action()
		if state.running then
			pause()
		else
			start()
		end
	end

	local action_button = {
		provider = function()
			if state.running then
				return icon_pause .. " Pause"
			end
			return icon_start .. " Start"
		end,
		mappings = {
			["<CR>"] = on_action,
			["<LeftMouse>"] = on_action,
		},
	}

	local reset_button = {
		provider = icon_reset .. " Reset",
		mappings = {
			["<CR>"] = function()
				stop()
			end,
			["<LeftMouse>"] = function()
				stop()
			end,
		},
	}

	local ButtonRow = utils.center(Line({
		action_button,
		{ provider = "  " },
		reset_button,
	}))

	Pomodoro = {
		update = { "User", pattern = "PomodoroTick" },
		ModeLine,
		Spacer,
		AsciiTimer,
		Spacer,
		ButtonRow,
	}
end

komado.setup({
	window = { position = "left", size = { ratio = 0.2, min = 20, max = 35 }, padding = 1 },
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
		Separator,
		Pomodoro,
		Separator,
		GitStatus,
		utils.vertical_align(),
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
