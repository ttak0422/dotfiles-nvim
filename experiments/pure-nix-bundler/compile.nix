# Pure evaluation only: no nixpkgs, derivations, fetches, or Lua execution.
{ root, features }:
let
  b = builtins;
  fail = msg: throw "pure-nix-poc: ${msg}";
  check = condition: message: value: if condition then value else fail message;
  fields = allowed: value: where:
    check (b.isAttrs value && b.all (key: b.elem key allowed) (b.attrNames value))
      "unknown field or non-attrset at ${where}" value;
  strings = value: b.isList value && b.all b.isString value;
  relative = path:
    b.isString path && b.match "[A-Za-z0-9_/-]+\\.[A-Za-z0-9]+" path != null
    && !(b.elem ".." (b.filter b.isString (b.split "/" path)))
    && b.substring 0 1 path != "/";
  file = path:
    check (relative path && b.pathExists (root + "/${path}")) "missing/invalid file ${b.toJSON path}" path;
  ids = check (b.isAttrs features) "features must be an attrset" (b.attrNames features);
  normalize = id:
    let
      f = fields [ "package" "activation" "scope" "requires" "hooks" "options" "updates" "docs" "tests" "evidence" ] features.${id} id;
      a = fields [ "kind" "command" "filetypes" ] f.activation "${id}.activation";
      kind = a.kind;
      scope = f.scope or "session";
      deps = f.requires or [ ];
      u = fields [ "events" "initial" ] (f.updates or { }) "${id}.updates";
      tests = b.mapAttrs (_: file) f.tests;
      valid = b.match "[A-Za-z][A-Za-z0-9_-]*" id != null
        && b.elem kind [ "startup" "command" "filetype" "dependency" ]
        && b.attrNames a == (if kind == "command" then [ "command" "kind" ] else if kind == "filetype" then [ "filetypes" "kind" ] else [ "kind" ])
        && b.elem scope [ "session" "buffer" ]
        && b.isAttrs (f.options or { })
        && strings deps && b.all (dep: b.elem dep ids) deps
        && ((f.package or null) == null || (b.isString f.package && b.match "[A-Za-z0-9_-]+" f.package != null))
        && b.all (dep: (features.${dep}.scope or "session") == "session") deps
        && (kind != "command" || (b.isString a.command && b.match "[A-Z][A-Za-z0-9]*" a.command != null))
        && (kind != "filetype" || (strings a.filetypes && a.filetypes != [ ]))
        && strings (u.events or [ ]) && b.isBool (u.initial or false)
        && (scope != "buffer" || kind == "filetype")
        && (kind != "filetype" || scope == "buffer")
        && b.all (event: b.elem event [ "TextChanged" "TextChangedI" "BufWritePost" ]) (u.events or [ ])
        && (scope == "buffer" || u == { });
    in check valid "invalid schema or dependency in ${id}" {
      inherit id scope;
      package = f.package or null;
      activation = a;
      requires = deps;
      hooks = file f.hooks;
      options = f.options or { };
      updates = { events = u.events or [ ]; initial = u.initial or false; };
      docs = file f.docs;
      inherit tests;
      evidence = file f.evidence;
      reloadPolicy = "restart-required";
    };
  normalized = b.listToAttrs (map (id: { name = id; value = normalize id; }) ids);
  # DFS follows stable IDs; cycle messages include the complete traversed path.
  visit = path: state: id:
    if b.elem id path then fail "dependency cycle: ${b.concatStringsSep " -> " (path ++ [ id ])}"
    else if b.elem id state then state
    else (b.foldl' (visit (path ++ [ id ])) state normalized.${id}.requires) ++ [ id ];
  order = b.foldl' (visit [ ]) [ ] ids;
  commandNames = map (f: f.activation.command) (b.filter (f: f.activation.kind == "command") (b.attrValues normalized));
  unique = values: b.foldl' (acc: value: if b.elem value acc then acc else acc ++ [ value ]) [ ] values;
  manifest = check (b.length commandNames == b.length (unique commandNames)) "duplicate command" {
    schemaVersion = 1;
    features = map (id: normalized.${id}) order;
  };
  json = b.toJSON manifest;
  delimiter = eq: if b.replaceStrings [ "]${eq}]" ] [ "" ] json != json then delimiter (eq + "=") else eq;
  eq = delimiter "=";
  section = f: ''
    ## ${f.id}

    - Activation: ${f.activation.kind}
    - Trigger: `${b.toJSON f.activation}`
    - Scope: ${f.scope}
    - Package: ${if f.package == null then "local hooks only" else f.package}
    - Requires: ${b.concatStringsSep ", " f.requires}
    - Options: `${b.toJSON f.options}`
    - Hooks: [${f.hooks}](../${f.hooks})
    - Documentation: [${f.docs}](../${f.docs})
    - Release evidence: [fixture](../${f.evidence})
    - Tests: ${b.concatStringsSep ", " (map (name: "[${name}](../${f.tests.${name}})") (b.attrNames f.tests))}
    - Reload: ${f.reloadPolicy}
    - Execution evidence: not run by the generator
  '';
in
# Force every field, including docs/tests/evidence paths, before any output.
b.deepSeq manifest {
  inherit manifest;
  lua = "-- Generated from config.nix; do not edit.\nreturn vim.json.decode([${eq}[${json}]${eq}])\n";
  handbook = ''
    # Isolated Pure Nix bundler fixture

    This is an experiment, not the live Neovim configuration.
    Source: [config.nix](../config.nix). No test success is inferred from generation.

    ## Phase outline

    - Register: command and filetype proxies
    - Prepare/load/setup: each feature waits for its requirements at its own trigger
    - Stable registry traversal (not runtime execution order): ${b.concatStringsSep ", " order}
    - Attach: matching buffers, including existing buffers, once per generation
    - Update: declared events and initial requests; latest result only
    - Dispose: invalidate generation, then release owned resources in reverse order

    ${b.concatStringsSep "\n" (map section manifest.features)}
  '';
}
