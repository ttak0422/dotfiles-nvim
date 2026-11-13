{ pkgs }:
{
  workflows = pkgs.runCommand "workflow-lint" { nativeBuildInputs = [ pkgs.actionlint ]; } ''
    actionlint ${../.github/workflows/flake-check.yml}
    touch "$out"
  '';
}
// pkgs.lib.optionalAttrs (pkgs.stdenv.hostPlatform.system == "aarch64-darwin") {
  jvm-runtimes = pkgs.runCommand "jvm-runtime-tests" { } ''
    check_java() {
      "$1/bin/java" -version > version.txt 2>&1
      grep -F "$2" version.txt
    }
    check_java ${pkgs.jdk8} '"1.8.0_512"'
    check_java ${pkgs.jdk11} '"11.0.33"'
    check_java ${pkgs.jdk17} '"17.0.21"'
    check_java ${pkgs.jdk21} '"21.0.13"'
    check_java ${pkgs.jdk25} '"25.0.5"'
    JAVA_HOME=${pkgs.jdk21} GRADLE_USER_HOME="$TMPDIR/gradle" \
      ${pkgs.gradle}/bin/gradle --version --offline --no-daemon > gradle.txt
    grep -F 'Gradle 8.14.6' gradle.txt
    grep -E 'Launcher JVM: +21.0.13' gradle.txt
    touch "$out"
  '';
}
