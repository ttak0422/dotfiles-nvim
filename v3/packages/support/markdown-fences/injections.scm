; Preserve stock injections outside filetype=markdown (notably Vimwiki).
; Markdown host trees keep only the fenced-code rule; injected Markdown is preserved.
(fenced_code_block
  (info_string
    (language) @injection.language)
  (code_fence_content) @injection.content)

((html_block) @injection.content
  (#v3-not-markdown-host?)
  (#set! injection.language "html")
  (#set! injection.combined)
  (#set! injection.include-children))

((minus_metadata) @injection.content
  (#v3-not-markdown-host?)
  (#set! injection.language "yaml")
  (#offset! @injection.content 1 0 -1 0)
  (#set! injection.include-children))

((plus_metadata) @injection.content
  (#v3-not-markdown-host?)
  (#set! injection.language "toml")
  (#offset! @injection.content 1 0 -1 0)
  (#set! injection.include-children))

([
  (inline)
  (pipe_table_cell)
] @injection.content
  (#v3-not-markdown-host?)
  (#set! injection.language "markdown_inline"))
