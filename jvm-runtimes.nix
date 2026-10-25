final: prev:
let
  zulu =
    package: jdkVersion: zuluVersion: hash:
    package.override {
      dists.aarch64-darwin = { inherit jdkVersion zuluVersion hash; };
    };
in
{
  gradle =
    (prev.gradle-packages.mkGradle {
      version = "8.14.6";
      hash = "sha256-eYjtBxsqB5AOLscV/KFcarcrzm20M68wH6f6fpQHvSQ=";
      defaultJava = final.jdk21;
    }).wrapped;
}
// prev.lib.optionalAttrs (prev.stdenv.hostPlatform.system == "aarch64-darwin") {
  # Keep each project JDK on its existing major version.
  jdk8 = zulu prev.jdk8 "8.0.512" "8.98.0.107" "sha256-8m4qkQYlQs8i7yFxslVuHD9Cz4fPF0JYs994QDZYkqo=";
  jdk11 = zulu prev.jdk11 "11.0.33" "11.92.109" "sha256-SUewH8siDuaXENv2M3X0YoaI2EdQ/M0on1ptYrSUqpQ=";
  jdk17 = zulu prev.jdk17 "17.0.21" "17.70.111" "sha256-jlFJXTT01aWwI+LlJcZa+z+xOeQFB/y8Pc+UnKE85VA=";
  jdk21 = zulu prev.jdk21 "21.0.13" "21.54.107" "sha256-doL8u8OhZDUtNsCclrKqkYQci7r9uamn9fBNttKQpiQ=";
  jdk25 = zulu prev.jdk25 "25.0.5" "25.38.107" "sha256-gOI/IC0YFemJyYAQLpufNMvNQN+aXJisjwoKpvSkV3Y=";
}
