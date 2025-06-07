(local hlchunk (require :hlchunk))

(local indent {:enable false})
(local line_num {:enable false})
(local blank {:enable false})
(local chunk {:enable true
              :chars {:horizontal_line "─"
                      :vertical_line "│"
                      :left_top "┌"
                      :left_bottom "└"
                      :right_arrow "─"}
              :style (. vim.g :terminal_color_8)
              :delay 0
              :use_treesitter true
              :exclude_filetypes {:copilot-chat true}})

(hlchunk.setup {: chunk : indent : line_num : blank})
