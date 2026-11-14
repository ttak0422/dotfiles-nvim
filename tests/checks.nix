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
      grep -E "$2" version.txt
    }
    check_java ${pkgs.jdk8} 'version "1\.8\.'
    check_java ${pkgs.jdk11} 'version "11\.'
    check_java ${pkgs.jdk17} 'version "17\.'
    check_java ${pkgs.jdk21} 'version "21\.'
    check_java ${pkgs.jdk25} 'version "25\.'
    JAVA_HOME=${pkgs.jdk21} GRADLE_USER_HOME="$TMPDIR/gradle" \
      ${pkgs.gradle}/bin/gradle --version --offline --no-daemon > gradle.txt
    grep -F 'Gradle 8.14.6' gradle.txt
    grep -E 'Launcher JVM: +21\.' gradle.txt
    touch "$out"
  '';
}
