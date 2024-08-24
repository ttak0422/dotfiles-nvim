-- [nfnl] Compiled from fnl/leap.fnl by https://github.com/Olical/nfnl, do not edit.
for _, K in ipairs({{{"n", "x", "o"}, "s", "<Plug>(leap-forward)", "Leap forward"}, {{"n", "x", "o"}, "S", "<Plug>(leap-backward)", "Leap backward"}}) do
  vim.keymap.set(K[1], K[2], K[3])
end
return nil
