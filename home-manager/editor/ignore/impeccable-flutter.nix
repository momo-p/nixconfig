{
  pkgs,
  src,
}:
pkgs.stdenv.mkDerivation {
  pname = "impeccable-flutter";
  version = "0.1.0";

  dontUnpack = true;
  dontStrip = true; # strip discards the AOT snapshot `dart compile exe` appends to the stub
  nativeBuildInputs = [pkgs.dart];

  buildPhase = ''
    runHook preBuild

    export HOME=$TMPDIR
    cp -r ${src}/detector detector
    chmod -R u+w detector
    cd detector

    mkdir -p .dart_tool
    cat > .dart_tool/package_config.json <<EOF
    {
      "configVersion": 2,
      "packages": [
        {
          "name": "impeccable_flutter",
          "rootUri": "../",
          "packageUri": "lib/",
          "languageVersion": "3.6"
        }
      ]
    }
    EOF

    dart compile exe bin/impeccable_flutter.dart -o impeccable-flutter

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 impeccable-flutter $out/bin/impeccable-flutter
    runHook postInstall
  '';
}
