local api = vim.api
assert(package.loaded.win_box, "WinBox must be configured on startup")
local box = require("win_box")

-- Inspect the pack directory as well as loaded modules: removed packages
-- must be absent, not merely deferred.
local installed = {}
local opt = vim.env.PLUGIN_TEST_BUNDLE .. "/pack/divine/opt"
for name in vim.fs.dir(opt) do
  local path = vim.uv.fs_realpath(opt .. "/" .. name)
  if path then installed[#installed + 1] = vim.fs.basename(path):lower() end
end
local function includes(fragment)
  return vim.iter(installed):any(function(name) return name:find("-" .. fragment .. "-", 1, true) end)
end
assert(includes("win-box-nvim"), "WinBox not present in runtime bundle")
for _, old in ipairs({
  "colorful-winsep-nvim", "nvim-window", "winresizer", "winshift-nvim", "smart-splits-nvim", "keep-split-ratio-nvim",
}) do
  assert(not includes(old), "legacy plugin still present: " .. old)
end
for _, keep in ipairs({ "neozoom-lua", "hud-nvim", "stickybuf-nvim" }) do
  assert(includes(keep), "unrelated window plugin missing: " .. keep)
end

-- Assert the existing dotfiles keys dispatch to the new public API.
local invoked = {}
local handlers = { "<C-w>H", "<C-w>J", "<C-w>K", "<C-w>L", "<C-w><C-w>", "<C-w>p", "<C-w>e" }
local originals = { move = box.move, swap = box.swap, pick = box.pick, adjust = box.adjust }
for name in pairs(originals) do
  box[name] = function(direction) invoked[#invoked + 1] = direction or name end
end
for _, key in ipairs(handlers) do
  local mapping = vim.fn.maparg(key, "n", false, true)
  assert(type(mapping.callback) == "function" and mapping.noremap == 1, "missing mapping: " .. key)
  mapping.callback()
end
for name, handler in pairs(originals) do box[name] = handler end
assert(vim.deep_equal(invoked, { "left", "down", "up", "right", "swap", "pick", "adjust" }), vim.inspect(invoked))

vim.cmd.only()
vim.cmd.enew()
vim.o.splitright = true
vim.cmd.vnew()
vim.cmd.wincmd("h")
local left = api.nvim_get_current_win()
local left_width = api.nvim_win_get_width(left)
local eventignore = vim.o.eventignore
local entered = 0
local group = api.nvim_create_augroup("WinBoxResizeCheck", { clear = true })
api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
  group = group,
  callback = function() entered = entered + 1 end,
})
box.resize("right", 4)
assert(api.nvim_win_get_width(left) == left_width + 4, "resize should grow the focused split")
assert(api.nvim_get_current_win() == left, "resize must retain focused window")
assert(entered == 0 and vim.o.eventignore == eventignore, "resize must avoid enter events and preserve eventignore")
box.resize("left", 4)
assert(api.nvim_win_get_width(left) == left_width, "resize should restore the original width")
api.nvim_del_augroup_by_id(group)

box.focus("right")
local right = api.nvim_get_current_win()
assert(right ~= left, "focus should move to the right split")
local left_buffer, right_buffer = api.nvim_win_get_buf(left), api.nvim_win_get_buf(right)
box.swap_buffers(left)
assert(api.nvim_win_get_buf(left) == right_buffer and api.nvim_win_get_buf(right) == left_buffer, "swap buffers")
box.swap_buffers(left)

-- Exercise the real mapped input, not just callback dispatch.
local function input(keys)
  api.nvim_feedkeys(vim.keycode(keys), "mx", false)
end
api.nvim_set_current_win(left)
local open_win, framed_hints = api.nvim_open_win, 0
api.nvim_open_win = function(buf, enter, config)
  if config.zindex == 55 and config.border == "single" and config.height > 1 and config.width > 1 then
    framed_hints = framed_hints + 1
  end
  return open_win(buf, enter, config)
end
input("<C-w>ps")
api.nvim_open_win = open_win
assert(framed_hints == 2, "picker must open two large framed hints")
assert(api.nvim_get_current_win() == right, "picker key should focus the second pane")
input("<C-w><C-w>a")
assert(api.nvim_win_get_position(left)[2] > api.nvim_win_get_position(right)[2],
  "swap key must exchange the native sibling splits")
assert(api.nvim_win_get_buf(left) == left_buffer and api.nvim_win_get_buf(right) == right_buffer,
  "native exchange must carry each window's buffer")
left, right = right, left

api.nvim_set_current_win(left)
local before = api.nvim_win_get_width(left)
input("<C-w>elq")
assert(api.nvim_win_get_width(left) == before and api.nvim_get_current_win() == left,
  "cancelling adjust must restore width and focus")
input("<C-w>el<CR>")
assert(api.nvim_win_get_width(left) > before and api.nvim_get_current_win() == left,
  "confirming adjust must retain width and focus")
input("<C-w>L")
assert(api.nvim_win_get_position(left)[2] > api.nvim_win_get_position(right)[2],
  "move key must move the native split rather than just focus it")

-- A top-left pane and a full-height right pane belong to different split groups.
-- The swap picker must exchange whole native windows rather than only buffers.
assert(vim.o.laststatus == 0 and vim.o.statusline == "%=", "fixture must use the real blank separator profile")
local top_left, across = right, left
api.nvim_set_current_win(top_left)
vim.o.splitbelow = true
vim.cmd.new()
local bottom_left = api.nvim_get_current_win()
api.nvim_set_current_win(top_left)
vim.wo[top_left].winbar = "WINBOX_TEST_WINBAR"
vim.wo[top_left].cursorline, vim.wo[across].cursorline = true, false
local p1, p2, p3 = api.nvim_win_get_position(top_left), api.nvim_win_get_position(across), api.nvim_win_get_position(bottom_left)
local b1, b2, b3 = api.nvim_win_get_buf(top_left), api.nvim_win_get_buf(across), api.nvim_win_get_buf(bottom_left)
input("<C-w><C-w>s")
assert(vim.deep_equal(api.nvim_win_get_position(top_left), p2)
  and vim.deep_equal(api.nvim_win_get_position(across), p1)
  and vim.deep_equal(api.nvim_win_get_position(bottom_left), p3), "cross-group swap must exchange only selected positions")
assert(api.nvim_win_get_buf(top_left) == b1 and api.nvim_win_get_buf(across) == b2
  and api.nvim_win_get_buf(bottom_left) == b3, "window IDs must retain their buffers")
assert(api.nvim_get_current_win() == top_left and vim.wo[top_left].winbar == "WINBOX_TEST_WINBAR"
  and vim.wo[top_left].cursorline and not vim.wo[across].cursorline, "swap must retain focus and window-local options")
