; Stock Markdown block highlights, excluded only from the host Markdown tree.
; Keep synchronized with the pinned parser query when updating Tree-sitter.

((setext_heading
  (paragraph) @markup.heading.1
  (setext_h1_underline) @markup.heading.1)
  (#v3-not-markdown-host?))

((setext_heading
  (paragraph) @markup.heading.2
  (setext_h2_underline) @markup.heading.2)
  (#v3-not-markdown-host?))

((atx_heading
  (atx_h1_marker)) @markup.heading.1
  (#v3-not-markdown-host?))

((atx_heading
  (atx_h2_marker)) @markup.heading.2
  (#v3-not-markdown-host?))

((atx_heading
  (atx_h3_marker)) @markup.heading.3
  (#v3-not-markdown-host?))

((atx_heading
  (atx_h4_marker)) @markup.heading.4
  (#v3-not-markdown-host?))

((atx_heading
  (atx_h5_marker)) @markup.heading.5
  (#v3-not-markdown-host?))

((atx_heading
  (atx_h6_marker)) @markup.heading.6
  (#v3-not-markdown-host?))

((info_string) @label
  (#v3-not-markdown-host?))

((pipe_table_header
  (pipe_table_cell) @markup.heading)
  (#v3-not-markdown-host?))

((pipe_table_header
  "|" @punctuation.special)
  (#v3-not-markdown-host?))

((pipe_table_row
  "|" @punctuation.special)
  (#v3-not-markdown-host?))

((pipe_table_delimiter_row
  "|" @punctuation.special)
  (#v3-not-markdown-host?))

((pipe_table_delimiter_cell) @punctuation.special
  (#v3-not-markdown-host?))

((indented_code_block) @markup.raw.block
  (#v3-not-markdown-host?))

(((fenced_code_block) @markup.raw.block
  (#set! priority 90))
  (#v3-not-markdown-host?))

((fenced_code_block
  (fenced_code_block_delimiter) @markup.raw.block
  (#set! conceal "")
  (#set! conceal_lines ""))
  (#v3-not-markdown-host?))

((fenced_code_block
  (info_string
    (language) @label
    (#set! conceal "")
    (#set! conceal_lines "")))
  (#v3-not-markdown-host?))

((link_destination) @markup.link.url
  (#v3-not-markdown-host?))

([
  (link_title)
  (link_label)
] @markup.link.label
  (#v3-not-markdown-host?))

(((link_label)
  .
  ":" @punctuation.delimiter)
  (#v3-not-markdown-host?))

([
  (list_marker_plus)
  (list_marker_minus)
  (list_marker_star)
  (list_marker_dot)
  (list_marker_parenthesis)
] @markup.list
  (#v3-not-markdown-host?))

((thematic_break) @punctuation.special
  (#v3-not-markdown-host?))

((task_list_marker_unchecked) @markup.list.unchecked
  (#v3-not-markdown-host?))

((task_list_marker_checked) @markup.list.checked
  (#v3-not-markdown-host?))

(((block_quote) @markup.quote
  (#set! priority 90))
  (#v3-not-markdown-host?))

(([
  (plus_metadata)
  (minus_metadata)
] @keyword.directive
  (#set! priority 90))
  (#v3-not-markdown-host?))

([
  (block_continuation)
  (block_quote_marker)
] @punctuation.special
  (#v3-not-markdown-host?))

((backslash_escape) @string.escape
  (#v3-not-markdown-host?))

((inline) @spell
  (#v3-not-markdown-host?))
