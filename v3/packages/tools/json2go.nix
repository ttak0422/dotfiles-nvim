{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "json2go";
  version = "0.2.2";

  # gopher.nvim uses olexsmir.xyz/json2go/cmd/json2go, not similarly named tools.
  src = fetchFromGitHub {
    owner = "olexsmir";
    repo = "json2go";
    tag = "v${version}";
    hash = "sha256-m//1MWEatyyJSt+MZ/1LzCA5Ia6snphb5KDeQmFyo1U=";
  };
  vendorHash = "sha256-0t5ul0FHBJw+xt9rBTcZeKa1wdHCNvbrUYZB8pACGvY=";
  subPackages = [
    "."
    "cmd/json2go"
  ];

  meta = {
    description = "Convert JSON to Go type annotations";
    homepage = "https://github.com/olexsmir/json2go";
    license = lib.licenses.unlicense;
    mainProgram = "json2go";
  };
}
