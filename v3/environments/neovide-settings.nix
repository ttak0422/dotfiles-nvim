# Neovide-only startup settings; shared core remains frontend-independent.
{
  startupConfig = ''
    if vim.g.neovide then
      for name, value in pairs({
        neovide_confirm_quit = false,
        neovide_cursor_animate_in_insert_mode = false,
        neovide_cursor_animation_length = 0.1,
        neovide_cursor_antialiasing = false,
        neovide_floating_corner_radius = 0.25,
        neovide_floating_shadow = false,
        neovide_hide_mouse_when_typing = true,
        neovide_input_ime = false,
        neovide_macos_simple_fullscreen = false,
        neovide_opacity = 1.0,
        neovide_padding_bottom = 5,
        neovide_padding_left = 5,
        neovide_padding_right = 5,
        neovide_padding_top = 10,
        neovide_window_blurred = true,
      }) do
        vim.g[name] = value
      end
      local function change_scale(factor)
        vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * factor
      end
      local function toggle_fullscreen()
        vim.g.neovide_fullscreen = not vim.g.neovide_fullscreen
      end
      local function toggle_blur()
        vim.g.neovide_window_blurred = not vim.g.neovide_window_blurred
      end
      local function paste_from_clipboard()
        local lines = vim.fn.getreg("+", 1, true)
        if #lines == 1 then
          vim.api.nvim_paste(lines[1], true, -1)
        else
          vim.api.nvim_put(lines, vim.fn.getregtype("+"), true, true)
        end
      end

      vim.o.guifont = "PlemolJP Console NF:h15"
      -- Ctrl+= needs no Shift; also accept Ctrl++ for other keyboard layouts.
      for _, key in ipairs({ "<C-=>", "<C-+>" }) do
        vim.keymap.set("n", key, function() change_scale(1.1) end)
      end
      vim.keymap.set("n", "<C-->", function() change_scale(1 / 1.1) end)
      vim.keymap.set("n", "<A-Enter>", toggle_fullscreen)
      vim.keymap.set("n", "<A-Tab>", toggle_blur)
      vim.keymap.set("i", "<D-v>", paste_from_clipboard)
      vim.keymap.set("c", "<D-v>", "<C-r>+")
      -- Avoid the shell's Ctrl+r mapping in terminal mode.
      vim.keymap.set("t", "<D-v>", "<C-\\><C-n>\"+pi")
      vim.api.nvim_create_user_command("ToggleNeovideFullScreen", toggle_fullscreen, {})
      vim.api.nvim_create_user_command("ToggleNeovideBlur", toggle_blur, {})
    end
  '';
}
