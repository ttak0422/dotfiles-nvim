{
  base = {
    activation.kind = "startup";
    hooks = "features/base/hooks.lua";
    docs = "features/base/README.md";
    tests.lifecycle = "tests/runtime.lua";
    evidence = "features/evidence.json";
  };
  picker = {
    package = "poc-picker";
    activation = { kind = "command"; command = "PocPick"; };
    requires = [ "base" ];
    hooks = "features/picker/hooks.lua";
    docs = "features/picker/README.md";
    tests.firstCommand = "tests/runtime.lua";
    evidence = "features/evidence.json";
  };
  metrics = {
    activation = { kind = "filetype"; filetypes = [ "markdown" ]; };
    scope = "buffer";
    requires = [ "base" ];
    hooks = "features/metrics/hooks.lua";
    updates = { events = [ "TextChanged" ]; initial = true; };
    docs = "features/metrics/README.md";
    tests.lifecycle = "tests/runtime.lua";
    evidence = "features/evidence.json";
  };
}
