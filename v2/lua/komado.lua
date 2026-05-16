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
  root = { Header, Spacer },
})

vim.api.nvim_create_user_command("KomadoToggle", function()
  komado.toggle()
end, {})
