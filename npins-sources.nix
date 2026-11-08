directory:
let
  data = builtins.fromJSON (builtins.readFile (directory + "/sources.json"));
  normalize =
    _: spec:
    if
      (spec.repository.type or null) == "GitHub"
      && !(spec.submodules or false)
      &&
        (spec.url or null)
        == "https://github.com/${spec.repository.owner}/${spec.repository.repo}/archive/${spec.revision}.tar.gz"
    then
      spec
      // {
        # Use GitHub's official archive host directly, preserving the pinned tree hash.
        url = "https://codeload.github.com/${spec.repository.owner}/${spec.repository.repo}/tar.gz/${spec.revision}";
      }
    else
      spec;
in
import directory {
  input = data // {
    pins = builtins.mapAttrs normalize data.pins;
  };
}
