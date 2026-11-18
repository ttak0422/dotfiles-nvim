{
  lib,
  stdenvNoCC,
  makeWrapper,
  git,
  fzf,
  gh,
  src,
}:
let
  versionMatch = builtins.match ".*GTR_VERSION=\"([0-9.]+)\".*" (
    builtins.readFile "${src}/bin/git-gtr"
  );
in
stdenvNoCC.mkDerivation {
  pname = "git-gtr";
  version = if versionMatch == null then "unstable" else builtins.head versionMatch;
  inherit src;

  nativeBuildInputs = [ makeWrapper ];
  dontConfigure = true;
  dontBuild = true;

  # git-gtr resolves its lib/ relative to the bin script, so keep the tree
  # intact under share/ and expose wrappers that inject the runtime tools.
  installPhase = ''
    runHook preInstall

    install -d $out/share/git-gtr
    cp -r bin lib adapters completions templates $out/share/git-gtr/
    patchShebangs $out/share/git-gtr/bin

    install -d $out/bin
    makeWrapper $out/share/git-gtr/bin/git-gtr $out/bin/git-gtr \
      --prefix PATH : ${lib.makeBinPath [ git fzf gh ]}
    makeWrapper $out/share/git-gtr/bin/gtr $out/bin/gtr \
      --prefix PATH : ${lib.makeBinPath [ git fzf gh ]}

    # Pre-generate zsh shell integration so it can be sourced reproducibly
    # instead of eval-ing the binary on every shell startup.
    HOME=$TMPDIR XDG_CACHE_HOME=$TMPDIR/cache \
      $out/bin/git-gtr init zsh > $out/share/git-gtr/init.zsh

    install -Dm644 completions/_git-gtr $out/share/zsh/site-functions/_git-gtr
    install -Dm644 completions/gtr.bash $out/share/bash-completion/completions/git-gtr
    install -Dm644 completions/git-gtr.fish $out/share/fish/vendor_completions.d/git-gtr.fish

    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    export PATH="$out/bin:${lib.makeBinPath [ git ]}:$PATH"
    bash ${./git-gtr-smoke.sh}
    runHook postInstallCheck
  '';

  meta = {
    description = "Git worktree runner with editor/AI integration (git gtr)";
    homepage = "https://github.com/coderabbitai/git-worktree-runner";
    license = lib.licenses.mit;
    mainProgram = "git-gtr";
    platforms = lib.platforms.unix;
  };
}
