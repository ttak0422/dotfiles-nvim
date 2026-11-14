final: prev: {
  gradle =
    (prev.gradle-packages.mkGradle {
      version = "8.14.6";
      hash = "sha256-eYjtBxsqB5AOLscV/KFcarcrzm20M68wH6f6fpQHvSQ=";
      defaultJava = final.jdk21;
    }).wrapped;
}
