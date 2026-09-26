{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs,
  makeWrapper,
}:

buildNpmPackage (finalAttrs: rec {
  pname = "mokuro-reader";
  version = "1.9.1";

  src = fetchFromGitHub {
    owner = "Gnathonic";
    repo = "mokuro-reader";
    tag = "v${finalAttrs.version}";
    hash = "sha256-EYZaGcvcC95yMIl9B76RX1G0Lx97GjLpazYOQs0xkXU=";
  };

  patches = [
    ./adapter-node.patch
  ];

  npmDepsHash = "sha256-MD/4h7A/FeeTSISKcB5CvGYL9ODB1D/PB4y+cj+mmPY=";

  nativeBuildInputs = [
    makeWrapper
  ];

  postInstall = ''
    mkdir -p $out/share/mokuro-reader
    cp -r build $out/share/mokuro-reader/

    makeWrapper ${nodejs}/bin/node $out/bin/mokuro-reader \
      --add-flags "$out/share/mokuro-reader/build/index.js"
  '';

  meta = {
    changelog = "https://github.com/Gnathonic/mokuro-reader/releases/tag/v${version}";
    description = "A mokuro reader written in svelte";
    homepage = "https://github.com/Gnathonic/mokuro-reader";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ nickthegroot ];
  };
})
