_: prev:
let
  inherit (prev) lib;
  version = "1.184.0";
  changelog = "https://github.com/semgrep/semgrep/blob/v${version}/CHANGELOG.md";
  srcHash = "sha256-mlveB6601Bo8spABv+M3pQt/3Hrk5a7xo2VV4QSe4VU=";
  pythonWheelTag = "cp310.cp311.cp312.cp313.cp314.py310.py311.py312.py313.py314";
  corePlatforms = {
    aarch64-darwin = {
      platform = "macosx_11_0_arm64";
      hash = "sha256-DOMGQXWkQjbdn9NWA2J+P1YTmsYeE8qWe64rdrLOyb8=";
    };
    aarch64-linux = {
      platform = "manylinux_2_34_aarch64";
      hash = "sha256-95TXxtMxJraIH4DQaVg+81tSvXltiCpfoknOESSro/M=";
    };
    x86_64-linux = {
      platform = "manylinux_2_34_x86_64";
      hash = "sha256-2EeruPtv3ed9njCmvIadv8to7/QULc13iXxSY1p2ANk=";
    };
  };

  # Semgrep 1.184 adds certifi>=2026.10.19. Keep the upstream requirement
  # and use nixpkgs' 2026.10.23 update in this application's Python scope.
  # https://github.com/NixOS/nixpkgs/commit/5ef3345a4800ef30ba03d7b9039dafed34f1fd0d
  pythonPackages = prev.python3Packages.overrideScope (
    _: pythonPrev: {
      certifi = pythonPrev.certifi.overridePythonAttrs (_: {
        version = "2026.10.23";
        src = prev.fetchFromGitHub {
          owner = "certifi";
          repo = "python-certifi";
          tag = "2026.10.23";
          hash = "sha256-uESJgC07To+bUePmwi180SCtAzAZkmEn1UolTWpB4X0=";
        };
      });
    }
  );

  semgrepCore = prev.semgrep.semgrep-core.overrideAttrs (old: {
    inherit version;
    src = prev.fetchPypi {
      pname = "semgrep";
      inherit version;
      format = "wheel";
      dist = pythonWheelTag;
      python = pythonWheelTag;
      inherit (corePlatforms.${prev.stdenv.hostPlatform.system}) platform hash;
    };
    meta = old.meta // {
      inherit changelog;
    };
  });
in
{
  # Remove this release override when the v3 nixpkgs pin packages 1.184.0+
  # with its declared MCP dependency. Do not relax mcp across its major API break.
  # https://github.com/semgrep/semgrep/blob/v1.184.0/cli/pyproject.toml
  semgrep = pythonPackages.toPythonApplication (
    (pythonPackages.semgrep.override {
      mcp = pythonPackages.mcp_1;
      semgrep-core = semgrepCore;
    }).overridePythonAttrs
      (old: {
        inherit version;
        src = prev.fetchFromGitHub {
          owner = "semgrep";
          repo = "semgrep";
          tag = "v${version}";
          hash = srcHash;
        };
        # Keep upstream's executable lookup and missing-core behavior intact.
        # Install the shared native binary in the standard wheel layout instead
        # of rewriting Python sources to return its Nix store path unconditionally.
        postPatch = "";
        postInstall = (old.postInstall or "") + ''
          coreDir="$out/${pythonPackages.python.sitePackages}/semgrep/bin"
          mkdir -p "$coreDir"
          ln -s ${lib.getExe semgrepCore} "$coreDir/semgrep-core"
          if [ -d ${semgrepCore}/bin/libs ]; then
            ln -s ${semgrepCore}/bin/libs "$coreDir/libs"
          fi
        '';
        pythonRelaxDeps = lib.remove "mcp" old.pythonRelaxDeps;
        dependencies = old.dependencies ++ [
          pythonPackages.certifi
          pythonPackages.structlog
        ];
        passthru = old.passthru // {
          # The release now includes generated interfaces directly.
          submodulesSubset = { };
          common = old.passthru.common // {
            inherit version srcHash pythonWheelTag;
            submodules = { };
            core = corePlatforms;
            meta = old.passthru.common.meta // {
              inherit changelog;
            };
          };
        };
        meta = old.meta // {
          inherit changelog;
        };
      })
  );
}
