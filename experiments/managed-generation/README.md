# Manager-owned generation switch POC

This is an isolated Lua experiment, not a replacement for the live configuration.
It follows the Pure Nix configuration proposal, but tests only the runtime boundary:
an immutable Nix-generated definition could supply each candidate; no Nix compiler,
package resolver, or live configuration integration is added here.

This experiment is based directly on `main`. It has no code dependency on
[the separate Pure Nix bundler POC, PR #32](https://github.com/ttak0422/dotfiles-nvim/pull/32).
The related Track design is `1793329558000` (hot swap and unload), with interface
proposal `1793321923000` and original design `1793293506000`.

## Try the fixture

```sh
NVIM_BIN=/path/to/neovim-unwrapped/bin/nvim \
  python3 experiments/managed-generation/tests/run.py
```

The runner creates temporary HOME/XDG directories and starts headless Neovim with
`-u NONE -i NONE`, empty VIMINIT/EXINIT, and no user configuration. Python 3.9+
and Neovim are the only dependencies. The intended version is Neovim 0.12.6.
The dedicated Ubuntu CI uses its distribution Neovim (currently 0.9.5) for this
limited API fixture; a passing result is not a promise of general 0.9.5 support.
The existing flake CI separately checks/builds the repository configuration; it
does not run this fixture.

## Small implemented interface

All names below belong to this experiment, not Nixvim or an implemented production
dotfiles-manager API. The counter is synthetic and has no upstream plugin release.

```lua
local Manager = dofile("experiments/managed-generation/manager.lua")
local definition = dofile("experiments/managed-generation/features/counter/definition.lua")
local manager = Manager.new()
local entry = manager.facade -- Keep this stable entry point.

manager:swap(definition("v1", 1))
entry.run()                             -- count = 1
manager:swap(definition("v2", 2))       -- migrate count -> total
assert(entry.read() == "v2")
assert(manager:snapshot().data.total == 1)
manager:close()
```

`definition` supplies `stateVersion`, plain `initial` data, optional `migrate`, and
synchronous `activate(ctx, state)`. Its returned service contains plain `state`
and callable methods. The context supports `own(disposer)`, a dedicated User
`autocmd`, and `guard(callback)` for each asynchronous request. This is not the
whole proposed DSL. In particular, `manager.current` is exposed for fixture
inspection, not a recommended public interface.

## Switch and failure contract

1. Validate the descriptor and plain initial state.
2. Stop the manager timer, quiesce dispatch, and advance the event epoch.
3. Copy the old versioned plain state; migrate that copy if its schema changes.
4. Activate the candidate synchronously with a resource ownership ledger.
5. Publish its service through the stable facade, then dispose the previous
   generation's ledger in reverse acquisition order.
6. Resume dispatch and the one manager-owned timer.

The manager owns one command, one dispatch autocmd, and one timer for its lifetime.
Generation-owned autocmds have separate IDs and disposers. Scheduled event and
timer calls capture the generation and event epoch. Per-request callbacks also
capture the epoch when the request starts. They are checked again on Neovim's
scheduled main loop before they may update state.

On a candidate activation/migration error, successful candidate cleanup retains
the old service and its unchanged state (`retainedPrevious`). Persistent old
registrations resume under a fresh event gate, but requests from before the
quiesce remain invalid. Fresh requests work again. If candidate cleanup or old
generation retirement fails, dispatch stops with `restartRequired`; the manager
does not claim a successful rollback. `errors` records callback/cleanup failures.

These guarantees assume cooperative, non-yielding candidate code that acquires
only ledger-owned reversible resources. The manager cannot prove or undo arbitrary
Lua effects. File writes, external requests, buffer mutation, shared globals,
untracked resources, and asynchronous activation violate this limited contract.
Even migration code executes in the editor and must obey it. This is not a general
transaction or an isolated sandbox for untrusted candidate code.

An old captured closure still calls old code. Only the stable facade redirects to
the current service; it does not revoke arbitrary references. No `package.loaded`
eviction or module unload is attempted. The fixture reserves its command/event
names and does not provide collision restoration after a third party overwrites
them. Plain state excludes closures, userdata, metatables, cycles and non-finite
numbers; copying does not preserve shared table identity.

## Evidence and limits

The adjacent [counter tests](features/counter/tests.lua) check:

- stable facade versus a surviving raw old closure;
- version 1 `count` to version 2 `total` migration and copied snapshots;
- twenty further switches with exactly one generation-owned autocmd and one
  stable dispatch autocmd, one command, and one manager timer;
- current callbacks accepted, old/queued asynchronous replies suppressed;
- activation/migration failure retains old state and cleans candidate resources;
- pre-quiesce requests remain invalid after recovery, fresh requests work;
- cleanup failures stop dispatch as `restartRequired`;
- close removes the command/autocmds, closes the timer and blocks queued work.

[The harness](tests/run.lua) also drives a real uv timer across a switch and close.
It checks that guarded and queued callbacks preserve nil arguments, including
trailing nil values and zero arguments.
Asynchronous replies are controlled callback fixtures, not external processes.
There is no measurement of actual module unloading or reclaimed memory.

Out of scope: third-party plugin unload, general Vimscript undo, dependency graphs,
shared LSP clients, native/FFI code, process cancellation, Nix GC roots, store
generation leases, crash recovery, live swaps, and complete rollback. They remain
design work in the linked Track note; this POC does not validate those capabilities.

Feature, tests, explanation, and synthetic evidence are colocated under
`features/counter/`. Actual test results come from execution and CI, not from
generating the evidence descriptor.
