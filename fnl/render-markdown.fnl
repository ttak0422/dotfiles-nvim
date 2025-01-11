(let [M (require :render-markdown)
      heading {:enabled true
               :render_modes false
               :sign false
               :icons ["󰼏 " "󰎨 " "󰼑 " "󰎲 " "󰼓 " "󰎴 "]
               :position :overlay
               :igns ["󰫎 "]
               :width :full
               :left_margin 0
               :left_pad 0
               :right_pad 0
               :min_width 0
               :border false
               :border_virtual false
               :border_prefix false
               :above "▄"
               :below "▀"}
      paragraph {:enabled true :render_modes false :left_margin 0 :min_width 0}
      code {:enabled true
            :render_modes false
            :sign true
            :style :full
            :position :left
            :language_pad 0
            :language_name true
            :disable_background [:diff]
            :width :full
            :left_margin 0
            :left_pad 0
            :right_pad 0
            :min_width 0
            :border :thin
            :above "▄"
            :below "▀"
            :highlight :RenderMarkdownCode
            :highlight_language nil
            :inline_pad 0
            :highlight_inline :RenderMarkdownCodeInline}
      dash {:enabled true
            :render_modes false
            :icon "─"
            :width :full
            :left_margin 0
            :highlight :RenderMarkdownDash}
      bullet {:enabled true
              :render_modes false
              :icons ["●" "○" "◆" "◇"]
              :ordered_icons (fn [_level index value]
                               (-> (vim.trim value)
                                   ((fn [v]
                                      (v:sub 1 (- (length v) 1))))
                                   (tonumber)
                                   ((fn [v] (if (> v 1) v index)))
                                   ((fn [v] (string.format "%d." v)))))
              :left_pad 0
              :right_pad 0
              :highlight :RenderMarkdownBullet}
      checkbox {:enabled true
                :render_modes false
                :position :inline
                :unchecked {:icon "󰄱"
                            :highlight :RenderMarkdownUnchecked
                            :scope_highlight nil}
                :checked {:icon "󰱒"
                          :highlight :RenderMarkdownChecked
                          :scope_highlight nil}
                :custom {}}
      pipe_table {:enabled true
                  :render_modes false
                  :preset :none
                  :style :full
                  :cell :padded
                  :padding 1
                  :min_width 0
                  :border ["┌"
                           "┬"
                           "┐"
                           "├"
                           "┼"
                           "┤"
                           "└"
                           "┴"
                           "┘"
                           "│"
                           "─"]
                  :alignment_indicator "━"
                  :head :RenderMarkdownTableHead
                  :row :RenderMarkdownTableRow
                  :filler :RenderMarkdownTableFill}
      callout {:note {:raw "[!NOTE]"
                      :rendered "󰋽 Note"
                      :hilight :RenderMarkdownInfo}
               :tip {:raw "[!TIP]"
                     :rendered "󰌶 Tip"
                     :hilight :RenderMarkdownSuccess}
               :important {:raw "[!IMPORTANT]"
                           :rendered "󰅾 Important"
                           :hilight :RenderMarkdownHint}
               :warning {:raw "[!WARNING]"
                         :rendered "󰀪 Warning"
                         :hilight :RenderMarkdownWarn}
               :caution {:raw "[!CAUTION]"
                         :rendered "󰳦 Caution"
                         :hilight :RenderMarkdownError}
               :abstract {:raw "[!ABSTRACT]"
                          :rendered "󰨸 Abstract"
                          :hilight :RenderMarkdownInfo}
               :summary {:raw "[!SUMMARY]"
                         :rendered "󰨸 Summary"
                         :hilight :RenderMarkdownInfo}
               :tldr {:raw "[!TLDR]"
                      :rendered "󰨸 Tldr"
                      :hilight :RenderMarkdownInfo}
               :info {:raw "[!INFO]"
                      :rendered "󰋽 Info"
                      :hilight :RenderMarkdownInfo}
               :todo {:raw "[!TODO]"
                      :rendered "󰗡 Todo"
                      :hilight :RenderMarkdownInfo}
               :hint {:raw "[!HINT]"
                      :rendered "󰌶 Hint"
                      :hilight :RenderMarkdownSuccess}
               :success {:raw "[!SUCCESS]"
                         :rendered "󰄬 Success"
                         :hilight :RenderMarkdownSuccess}
               :check {:raw "[!CHECK]"
                       :rendered "󰄬 Check"
                       :hilight :RenderMarkdownSuccess}
               :done {:raw "[!DONE]"
                      :rendered "󰄬 Done"
                      :hilight :RenderMarkdownSuccess}
               :question {:raw "[!QUESTION]"
                          :rendered "󰘥 Question"
                          :hilight :RenderMarkdownWarn}
               :help {:raw "[!HELP]"
                      :rendered "󰘥 Help"
                      :hilight :RenderMarkdownWarn}
               :faq {:raw "[!FAQ]"
                     :rendered "󰘥 Faq"
                     :hilight :RenderMarkdownWarn}
               :attention {:raw "[!ATTENTION]"
                           :rendered "󰀪 Attention"
                           :hilight :RenderMarkdownWarn}
               :failure {:raw "[!FAILURE]"
                         :rendered "󰅖 Failure"
                         :hilight :RenderMarkdownError}
               :fail {:raw "[!FAIL]"
                      :rendered "󰅖 Fail"
                      :hilight :RenderMarkdownError}
               :missing {:raw "[!MISSING]"
                         :rendered "󰅖 Missing"
                         :hilight :RenderMarkdownError}
               :danger {:raw "[!DANGER]"
                        :rendered "󱐌 Danger"
                        :hilight :RenderMarkdownError}
               :error {:raw "[!ERROR]"
                       :rendered "󱐌 Error"
                       :hilight :RenderMarkdownError}
               :bug {:raw "[!BUG]"
                     :rendered "󰨰 Bug"
                     :hilight :RenderMarkdownError}
               :example {:raw "[!EXAMPLE]"
                         :rendered "󰉹 Example"
                         :hilight :RenderMarkdownHint}
               :quote {:raw "[!QUOTE]"
                       :rendered "󱆨 Quote"
                       :hilight :RenderMarkdownQuote}
               :cite {:raw "[!CITE]"
                      :rendered "󱆨 Cite"
                      :hilight :RenderMarkdownQuote}}
      link {:enabled true
            :render_modes false
            :footnote {:superscript true :prefix "" :suffix ""}
            :image "󰥶 "
            :email "󰀓 "
            :hyperlink "󰌹 "
            :highlight :RenderMarkdownLink
            :wiki {:icon "󱗖 " :highlight :RenderMarkdownWikiLink}
            :custom {:web {:pattern :^http :icon "󰖟 "}
                     :youtube {:pattern "youtube%.com" :icon "󰗃 "}
                     :github {:pattern "github%.com" :icon "󰊤 "}
                     :neovim {:pattern "neovim%.io" :icon " "}
                     :stackoverflow {:pattern "stackoverflow%.com"
                                     :icon "󰓌 "}
                     :discord {:pattern "discord%.com" :icon "󰙯 "}
                     :reddit {:pattern "reddit%.com" :icon "󰑍 "}}}
      sign {:enabled true :highlight :RenderMarkdownSign}
      indent {:enabled false :per_level 0 :skip_heading false}]
  (M.setup {: heading
            : paragraph
            : code
            : dash
            : bullet
            : checkbox
            : pipe_table
            : callout
            : link
            : sign
            : indent
            :quote {:enabled true
                    :render_modes false
                    :icon "▋"
                    :repeat_linebreak false
                    :highlight :RenderMarkdownQuote}}))

(vim.cmd :RenderMarkdown)
