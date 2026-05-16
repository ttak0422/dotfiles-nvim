local komado = require("komado")
local utils = require("komado.utils")
local Line = require("komado.dsl").Line

local Spacer = Line({ provider = "" })
local Separator = utils.separator("─", "Comment")

local Header
do
  local Name = { provider = "■ komado " }

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

  Header = { Line({ Name, utils.horizontal_align(), Clock }), Separator }
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
          { provider = "  ", hl = "Comment" },
          { provider = item.label, hl = "Identifier" },
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

komado.setup({
  window = { position = "left", size = { ratio = 0.2, min = 20, max = 35 } },
  mappings = {
    q = function()
      komado.close()
    end,
    r = function()
      komado.redraw()
    end,
  },
  root = { Header, Spacer, GitStatus },
})

vim.api.nvim_create_user_command("KomadoToggle", function()
  komado.toggle()
end, {})
