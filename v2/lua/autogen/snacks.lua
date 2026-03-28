-- [nfnl] v2/fnl/snacks.fnl
local snacks = require("snacks")
local dashboard = {width = 60, pane_gap = 1, preset = {keys = {{icon = "\239\133\155 ", key = "e", desc = "New File", action = ":ene | startinsert"}, {icon = "\239\128\162 ", key = "f", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')"}, {icon = "\239\128\130 ", key = "p", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')"}, {icon = "\239\131\133 ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')"}, {icon = "\243\176\166\155 ", key = "s", desc = "Restore Session", section = "session"}, {icon = "\239\144\166 ", key = "q", desc = "Quit", action = ":qa"}}}, sections = {{section = "header"}, {section = "keys", gap = 1, padding = 1}}}
local bigfile = {notify = true, size = (1 * 1024 * 1024), line_length = 2000}
return snacks.setup({dashboard = dashboard, bigfile = bigfile})
