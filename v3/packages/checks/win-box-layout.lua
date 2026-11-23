local api = vim.api
assert(package.loaded.win_box, "WinBox must be configured on startup")

local function input(keys)
  api.nvim_feedkeys(vim.keycode(keys), "mx", false)
end

vim.cmd.only()
vim.cmd.enew()
local left = api.nvim_get_current_win()
vim.cmd("rightbelow vnew")
local right = api.nvim_get_current_win()
local left_buffer, right_buffer = api.nvim_win_get_buf(left), api.nvim_win_get_buf(right)

api.nvim_set_current_win(left)
input("<C-w>ps")
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
assert(api.nvim_win_get_position(left)[2] > api.nvim_win_get_position(right)[2]
  and api.nvim_get_current_win() == left, "move right must shift the focused split")
input("<C-w>H")
assert(api.nvim_win_get_position(left)[2] < api.nvim_win_get_position(right)[2]
  and api.nvim_get_current_win() == left, "move left must shift the focused split")
input("<C-w>L")

-- A top-left pane and a full-height right pane belong to different split groups.
-- The swap picker must exchange whole native windows rather than only buffers.
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

-- Vertical direction keys should also shift the focused window, not only focus a neighbor.
vim.cmd.tabnew()
local top = api.nvim_get_current_win()
vim.cmd("rightbelow new")
local bottom = api.nvim_get_current_win()
api.nvim_set_current_win(top)
input("<C-w>J")
assert(api.nvim_win_get_position(top)[1] > api.nvim_win_get_position(bottom)[1]
  and api.nvim_get_current_win() == top, "move down must shift the focused split")
input("<C-w>K")
assert(api.nvim_win_get_position(top)[1] < api.nvim_win_get_position(bottom)[1]
  and api.nvim_get_current_win() == top, "move up must shift the focused split")
