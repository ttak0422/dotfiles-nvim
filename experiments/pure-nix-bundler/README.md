# Pure Nix bundler experiment

This isolated proof of concept turns a small Nix feature registry into a deterministic
manifest, Lua plan, and human-readable phase/plugin outline. A separate Lua runtime
exercises those declarations using synthetic packages and controlled asynchronous
replies. It does not import the live `v2` configuration, change pins, or replace Bundler.

Design references in the private Track vault:

- `1793293506000`: 次期Neovimプラグインマネージャー構想: Pure Nixとフェーズ設計
- `1793321923000`: 次期Neovim構成: Pure Nixバンドラーの想定インターフェース

These references explain the intent; Track is not a generation/build dependency.

## Try it

Requires Nix (`nix-instantiate`), Python 3.9+, and Neovim 0.9+ on PATH.
No `nix develop`, package fetch, or native build is needed. The test runner uses
temporary XDG directories and `-u NONE -i NONE`; it does not connect to your editor.

```sh
python3 experiments/pure-nix-bundler/tests/run.py
python3 experiments/pure-nix-bundler/generate.py
```

Generation writes ignored `generated/{manifest.json,plan.lua,handbook.md}`. Open
`generated/handbook.md` to follow the links to adjacent hook, test and evidence files.
The Nix compiler is the generator; Python only evaluates it and materializes outputs.
`NVIM_BIN` and `NIX_INSTANTIATE` can select already installed executables. An unwrapped
Neovim is recommended if your wrapper injects configuration independently of `-u NONE`.
If using `generate.py --out`, keep the output one level below this experiment for
the relative handbook links to resolve.

## One registry, several views

```text
config.nix + adjacent hooks/docs/tests + fixture evidence
                     │ compile.nix (pure builtins, no nixpkgs)
                     ▼
                normalized manifest
              ┌──────┼────────────┐
              ▼      ▼            ▼
          JSON    Lua plan    Markdown handbook
                     │
                     ▼ runtime.lua inside isolated Neovim
         startup / command / FileType → attach → update → dispose
```

For example, `picker` in [config.nix](config.nix) requires `base` and activates on
`PocPick`. Its [hooks](features/picker/hooks.lua) record prepare/setup; the optional
[package fixture](fixtures/pack/poc/opt/poc-picker/plugin/picker.lua) registers the
real command. The runtime captures the first invocation, ensures the dependency,
removes its proxy, runs `prepare → packadd → setup`, then delegates structured
arguments, bang, range and modifiers. This does not establish Telescope compatibility.

`metrics` selects Markdown buffers, attaches existing buffers and the first new
FileType buffer once, and requests initial/`TextChanged` updates. Its adjacent
[provider](features/metrics/hooks.lua) lets tests deliver replies in a chosen order.
`latest` captures the scope generation, request identity and changedtick. Superseding
work requests cancellation; disposal invalidates the generation before cleanup.
The guard is checked inside the scheduled apply, including when cancellation fails.
Completed work is removed from the resource ledger. Owned resources are released in
reverse order, and shared session dependencies outlive an individual buffer.

## Implemented subset of the interface proposal

| Proposal concept | This experiment |
| --- | --- |
| Profile / `nextNvim.features` | Direct registry in `config.nix`, no Nix module wrapper |
| IDs and required dependencies | Attrset IDs, session-only `requires`, stable DFS with cycle paths |
| Activation | Startup, one command per feature, FileType for buffer features, dependency-only |
| Phases | Register, prepare, optional packadd, setup, buffer attach/update, owned cleanup |
| Scope | Session and buffer; first FileType plus existing-buffer catch-up |
| Hook exports | One adjacent Lua table with fixed hook names; no configurable export mapping |
| Async context | `ctx:latest(key, begin, apply)` and `ctx:own(cleanup)`; controlled callback provider |
| Reload | Always `restart-required`; cleanup is not third-party package unloading |
| Docs/evidence/tests | Explicit adjacent paths in the same manifest; evidence is marked as fixture |

Unknown top-level fields, invalid scope/activation, missing files, unknown dependencies,
cycles, duplicate commands and unsupported update events are rejected at evaluation.
Lua hook semantics cannot be validated by Nix. Hook definition modules must be free of
side effects; explicit hook failures are recorded and block dependents. Managed partial
resources are cleaned, while unrelated startup features continue.

## Deliberate limits

- No real plugin compatibility, completion proxy, key/module trigger, `before/after`
  ordering DSL, window scope, or multiple registries in one process.
- No external process launcher, timeout/debounce, LSP/native build, or downloader.
  The asynchronous fixture is controlled, not an OS-process cancellation guarantee.
- No automatic hot reload, `package.loaded` clearing, or third-party rollback.
  Loaded package commands intentionally remain after runtime cleanup; restart Neovim
  for another configuration generation. Cleanup does not make a package unloadable.
- No Org/Track input, AI calls during evaluation, runtime updates, or automatic merge.
- No PASS status generated from manifest evaluation. Test execution is a separate step.

## What the tests establish

[tests/run.py](tests/run.py) compares repeated byte-identical Nix outputs, checks
source/test/doc paths, and rejects representative invalid inputs. It then runs the
generated Lua plan in a temporary editor. Feature-local contracts live beside
[picker hooks](features/picker/tests.lua) and [metrics hooks](features/metrics/tests.lua).
The shared [integration harness](tests/runtime.lua)
covers dependency/phase order, first command context, first FileType and catch-up,
duplicate attachment, response reordering, changedtick changes, cancellation failure,
scheduled callbacks after disposal, reverse cleanup, fresh generations, rename,
filetype change, buffer deletion, two windows, and isolated dependency failure.
The feature-local dependency regression also checks that loading a command feature
through `requires` transfers proxy ownership before the plugin registers its real
command, so cleanup preserves that real command.

These are behavioral fixtures, not proof that all plugin or interactive UI behavior
works. The dedicated workflow runs the same small tests; the repository's existing
flake workflow remains unchanged.
