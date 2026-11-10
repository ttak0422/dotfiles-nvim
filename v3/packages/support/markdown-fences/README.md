# Markdown: fenced-language highlighting without host inline parsing

This v3-only configuration keeps Neovim's real Markdown **block** parser to find
CommonMark code fences. It suppresses host Markdown highlights and non-fence
injections, especially `markdown_inline`, while retaining normal Tree-sitter
highlighting inside language-labelled fences. It adds no plugin and does not
change v2.

## Behavior and trade-offs

- Backtick/tilde fences, nested list/blockquote fences, language aliases and
  nested languages use the installed parsers and their stock queries. This also
  preserves a Markdown document embedded inside a `markdown` fence.
- Ordinary prose, headings, emphasis, links, tables, single-backtick code spans,
  HTML blocks and YAML/TOML frontmatter are not syntax-highlighted. Fence
  delimiters remain visible. No Vim-regex syntax fallback is enabled.
- Unlabelled and unsupported-language fences remain plain text.
- Markdown image.nvim automatic rendering is disabled. Its Vimwiki integration
  remains enabled. Explicit preview commands are not changed by this patch.
- Markdown skips Tree-sitter indent and uses UFO's indent provider. Structural
  heading folding is therefore not preserved. Native heading navigation still
  uses the block parser; its `]]` behavior is tested.
- Features that require Markdown inline nodes (for example inline-node-aware
  text objects or tab-out decisions) can have less information. Other languages
  and their queries are not disabled.

The query predicates distinguish the host document from an injected Markdown
document by the captured node's tree root: the host starts on the first buffer row (including a literal BOM),
whereas fenced content starts after its opener’s row. String parsers and other buffer
filetypes, including Vimwiki, retain the stock queries. Queries are installed
before native ftplugins create a cached parser. Filetype changes invalidate
cached injections without replacing the native parser or modifying private
parser/highlighter fields.

This is **not** a parser-free or viewport-only implementation. The entire
Markdown block tree is still maintained. The preserved non-Markdown HTML rule
has `injection.combined`, which makes Neovim scan the whole document for injection
matches even when the predicate excludes that rule in a Markdown host. Very
large uninterrupted paragraphs can therefore still be slow. The copied block
highlight and injection queries must be checked against the pinned upstream
queries when updating Tree-sitter.

## Regression checks

Run on the supported v3 host:

```sh
nix build .#checks.aarch64-darwin.markdown-fences --no-link --print-build-logs
```

The check uses the actual configured v3 editor with an attached UI and isolated
writable state. It covers real captures for Lua, Vimscript, Bash and Python;
`sh` alias; plain/unknown fences; exact code-tree boundaries for short/long
closers, indentation, lists, quotes and repeated fences; unclosed fences;
language/boundary edits; literal BOMs; nested Markdown/Lua fences; both Vimwiki/Markdown opening
orders; filetype transitions; native heading navigation; UFO/indent policy;
ordinary Lua; and Vimwiki image discovery/string-parser behavior.

## Observational performance comparison

Measured on a local Apple Silicon Mac with Neovim 0.12.6 and the complete v3
profile, comparing base commit `3b26266c` with this change. Both sides use an
embedded 120×40 UI, wrapping off, fresh temporary HOME/XDG directories and
synthetic `.md` files. No preview is open. Other configured plugins, including
autosave, remain active. Startup and the initial one-second settle are excluded.

Two fresh editor runs per fixture/profile, alternating profile order; five
operations of each type per run. All wall times include an identical **100 ms
event-drain wait**, so these are comparable scripted operation timings, not
keystroke-to-pixel latency measurements. The figures below are medians of ten
operations; saving/indent have only two samples each. No timing is a CI gate.

| Fixture | Operation | Base (ms) | Changed (ms) |
|---|---|---:|---:|
| Normal: 1,000 lines, ~17 KB, 100 fences across 10 languages | Prose edit | 390.6 | 128.3 |
| Normal | Fenced code edit | 546.6 | 129.3 |
| Normal | Move 5 lines | 118.4 | 109.4 |
| Dense: 1,000 lines, ~624 KB, 900 continuous prose lines + 10 fences | Prose edit | 1,675.8 | 462.0 |
| Dense | Fenced code edit | 548.2 | 285.5 |
| Dense | Move 5 lines | 144.9 | 144.4 |

Prose-edit ranges were 277–555 ms versus 123–170 ms for the normal fixture, and
1,492–2,137 ms versus 457–485 ms for the dense fixture. Dense prose-edit C parser
time had a median of 467 ms in `markdown_inline` before this change and zero
afterward. The block parser still took about 140 ms on both sides. This confirms
that inline parsing was removed without claiming all remaining time is parser
work. The comparison measures the whole configuration change, including image,
indent and folding changes; it does not isolate their individual contributions.

Save medians were 289/134 ms (normal) and 122/128 ms (dense), before/after.
Indent medians were 117/120 ms and 113/107 ms. These small two-sample results do
not establish a save, movement or indent speedup. All eight editor sessions
reported an empty `v:errmsg`. This has not been validated against the user's
specific slow project, and the pathological fixture remains noticeably slow.

To repeat, obtain both built `v3/default` binaries and run with a Python
environment containing `pynvim`:

```sh
python benchmark.py /path/to/base/bin/nvim /path/to/changed/bin/nvim 2 > results.jsonl
```

The script creates and removes only its own temporary files. The configured
editor needs ordinary local process/IPC access; a syscall-restricted sandbox
blocked startup in an initial attempt. Parser-time instrumentation wraps a
private Neovim method only in this benchmark, never in the shipped configuration.
