{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage (finalAttrs: {
  pname = "salt-rim";
  version = "4.14.1";

  src = fetchFromGitHub {
    owner = "karlomikus";
    repo = "vue-salt-rim";
    tag = "v${finalAttrs.version}";
    hash = "sha256-2UbKnT0lMXesd9ZUcgXF6y7NXFivwJeZaE41IXQqGHE=";
  };

  npmDepsHash = "sha256-wc6lk/+g8IyidauqajjWTQugcgH0yAP+AARTc7AYcug=";

  installPhase = ''
    mkdir -p $out
    cp -r dist/* $out/
  '';

  meta = {
    description = "Salt Rim - Bar Assistant web client";
    homepage = "https://github.com/karlomikus/vue-salt-rim";
    changelog = "https://github.com/karlomikus/vue-salt-rim/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nickthegroot ];
    platforms = lib.platforms.all;
  };
})
