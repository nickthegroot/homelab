{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs,
  makeWrapper,
}:

buildNpmPackage (finalAttrs: rec {
  pname = "mokuro-reader";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "Gnathonic";
    repo = "mokuro-reader";
    tag = "v${finalAttrs.version}";
    hash = "sha256-roVteKQwrlLj7Lgtq3H/HL9NrOZ8hUUjju8Cejs8How=";
  };

  patches = [
    ./adapter-node.patch
  ];

  npmDepsHash = "sha256-+t9FJb41xr70lrw9qOCk3UP0CNq9dc+n+DZ8JQ0Lgvw=";

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
