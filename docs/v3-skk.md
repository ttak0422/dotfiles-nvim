# v3 Goda SKK

## Scope and upstream contract

This is a separate profile layered on the zero-plugin divine foundation in
[PR #46](https://github.com/ttak0422/dotfiles-nvim/pull/46). It leaves `v3-default`,
v2, its skkeleton configuration and its pins unchanged. Launch with
`nix run .#v3-skk`. No change to the user's installed Neovim is required.

The upstream projects are **Shougo/goda.vim** and **Shougo/goda-skk.vim**;
`Shougo/goda.nvim` does not exist at the time of this check (2026-11-08 JST).
Goda is the Go-based framework, not itself an input method. SKK requires a
user-owned Go program calling `engine.Main(engine.Config{...})`, plus the
editor-side scripts and a dictionary. Upstream requires Go >= 1.26 for builds
and Neovim >= 0.11. The locked toolchain provides Go 1.26.7; this repository's
Neovim overlay provides 0.12.6. The upstream APIs are early and may change.

Pinned upstreams:

- [goda.vim v0.7.2](https://github.com/Shougo/goda.vim/tree/8399891df7fd77eee0473003201f9960dfbd8ebb)
- [goda-skk.vim v0.3.3](https://github.com/Shougo/goda-skk.vim/tree/b138f25d97610f8dc5cd644fc05797728ecf62f4)
- [SKK configuration/API](https://github.com/Shougo/goda-skk.vim/blob/b138f25d97610f8dc5cd644fc05797728ecf62f4/doc/goda_skk.txt)

The editor scripts are loaded eagerly through divine, with goda explicitly in
`dependPlugins`. Divine ignores nixpkgs' implicit plugin dependencies for
loading. Its `onEvents` only defers a node with `lazy = true`, and an
InsertEnter-only configuration would not cover initial command-line or terminal
use. There is little reason to add event triggers here: goda has no `plugin/`
script, and SKK's actual Go process starts on the first enabled key.

## Decision: native Nix packaging, existing flake lock

**Use non-flake inputs in `flake.lock`, `buildVimPlugin`, and `buildGoModule`.**
npins is also Nix-compatible; the real choice is source-lock ownership, not
npins versus reproducible builds. Both approaches still need the Go derivation.

A temporary npins 0.5.0 experiment, separate from the repository, pinned and
fetched the same tags:

```sh
npins init --bare
npins add github Shougo goda.vim --at v0.7.2
npins add github Shougo goda-skk.vim --at v0.3.3
npins get-path goda.vim
npins get-path goda-skk.vim
```

The npins and flake fetches produced **identical revisions, NAR hashes and store
paths** for both sources. The hashes are respectively:

- `sha256-o/mmMjAEQ14jYYj0SNc//QKh7i/MniMayClJtVtAqiI=`
- `sha256-fAbj82ZOCbgmUjWB15e/hzabsME/8OB5Wg4DzJm9HMs=`

### Trade-offs

- **Reproducibility:** both lock exact revisions and content hashes. The Go
  dependency vendor tree is independently pinned by `vendorHash`; `go.sum`
  verifies x/text. The existing dictionary revision is reused unchanged.
- **Caching:** neither lock format creates a binary-cache advantage. The
  sources were deduplicated in this experiment; compiled outputs can be
  substituted only when a cache contains the matching derivations. This PR
  does not claim an upstream prebuilt Goda cache. A warm repeated Nix build
  reuses the local outputs.
- **Updates:** npins can track upstream releases automatically and fits a large
  per-profile plugin collection, as v2 already does. Two native inputs avoid
  adding another lock/loader for v3 and work with the repository's existing
  flake workflow. Tags are intentionally fixed: changing to a new release is
  explicit, followed by a lock refresh and regression checks.
- **nixpkgs availability:** evaluation of the locked `pkgs.vimPlugins` found no
  attributes containing `goda` or `skk`. There is no existing package to reuse
  here. We use nixpkgs' standard builders, not an invented nixpkgs Goda package.
- **Dependency duplication:** local Go module replacements point to the same
  locked sources used for Vim scripts, avoiding script/binary version drift.
  Relative copies keep store references out of the fixed-output vendor tree.
  Go vendors required packages from those sources plus x/text. The optional
  goda-cmp plugin is not installed or built into this standalone engine.
  Existing `pkgs.skk-dict` is shared instead of fetching a second dictionary.

If v3 grows into a large independently updated plugin set, adopting npins for
that set is reasonable. It is unnecessary for these two sources today.

## Runtime and state

- `v3/skk/config/main.go` owns the backend configuration. Go and Deno are not
  runtime dependencies; `g:goda_skk#binary` points to the Nix-built executable.
- `SKK-JISYO.L` is read from the store using explicit `euc-jp` decoding.
- `NVIM_APPNAME=nvim-v3-skk` isolates the profile. A private state directory is
  created on first use, with UTF-8 learning in
  `stdpath('state')/goda-skk/SKK-JISYO.user`.
- `<C-j>` enables SKK in insert, command-line and terminal modes. Standard
  upstream conversion markers remain visible. `jk` preserves the v2 escape
  rule; `EggLikeNewline` confirms a conversion with Enter without adding a line.
- No yaskkserv probe, server connection, Google API, completion framework or
  skkeleton migration is added. Existing user dictionaries are not modified.
- Upstream v0.3.3 user-dictionary writes have no cross-process lock and use a
  shared temporary filename. Concurrent learning in multiple `v3-skk` editors
  can race, lose learned entries or fail a write. Use one learning session at
  a time for now; separate profiles/state roots avoid sharing that file. This
  early-upstream limitation is not fixed by the Nix packaging.
- Do not call `goda_skk#build()`: the Nix store binary is immutable. Rebuild the
  profile after editing its configuration.

### Updating

1. Change the desired release tags in `flake.nix`, and keep the requirements in
   `v3/skk/config/go.mod` aligned with them/upstream dependencies.
2. Run `nix flake update goda goda-skk` and review that unrelated inputs did not
   change. Local replacements mean the flake source is authoritative.
3. Set `vendorHash = pkgs.lib.fakeHash`, build `.#v3-skk-backend`, and replace
   it with the reported hash. Do this on source changes even if old vendor
   outputs are already cached; otherwise an old vendor tree can be reused.
4. Update `go.sum` if external Go dependencies changed, then run the checks below.

## Verification

The integration check starts actual headless embedded Neovim processes and
sends input through the native RPC input API, rather than calling engine
handlers directly. It uses temporary HOME/XDG directories and has no Go on
PATH. It covers:

- first insert-mode activation and あいうえお;
- real EUC-JP dictionary conversion, candidate cycling and confirmation;
- user-dictionary persistence and learned-candidate ordering after restart;
- `jk` escape and input-method disable;
- command-line and terminal activation as the first use in fresh editors;
- mappings, packaged executable availability, isolated app name and two-plugin
  divine graph, with no extra runtime packages.

Run:

```sh
nix build .#v3-skk .#checks.aarch64-darwin.v3-skk --no-link --print-build-logs
nix flake check --print-build-logs
nix flake check --no-build --all-systems
nix build .#bundler-nvim-v2 --no-link --print-build-logs
```

macOS execution and Linux evaluation are separate claims. Linux runtime and
interactive GUI rendering are not tested by the headless macOS check.
