(let [M (require :hlchunk)
      chunk {:enable true
             :chars {:horizontal_line "─"
                     :vertical_line "│"
                     :left_top "┌"
                     :left_bottom "└"
                     :right_arrow "─"}
             :style (. vim.g :terminal_color_8)
             :delay 0
             :use_treesitter true
             :exclude_filetypes {:copilot-chat true}}
      indent {:enable false}
      line_num {:enable false}
      blank {:enable false}]
  (M.setup {: chunk : indent : line_num : blank}))
