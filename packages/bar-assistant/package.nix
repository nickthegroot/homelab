{
  lib,
  dataDir ? "/var/lib/bar-assistant",
  fetchFromGitHub,
  php84,
  vips,
}:

let
  php = php84.withExtensions (
    { all, enabled }:
    enabled
    ++ [
      all.ffi
      all.redis
    ]
  );
in
php.buildComposerProject2 (finalAttrs: rec {
  pname = "bar-assistant";
  version = "5.14.0";

  src = fetchFromGitHub {
    owner = "karlomikus";
    repo = "bar-assistant";
    tag = "v${version}";
    hash = "sha256-0OKoaOEq1VTQIeHVzQKzOL2fvQiT2jUQSfFT9jCZQIY=";
  };

  vendorHash = "sha256-NgOoXjrpkS/cVVLzWW2ccCgiLkOJtrZxmoKgVB9Vi1Y=";

  buildInputs = [ vips ];

  composerStrictValidation = false;

  postInstall = ''
    bar_out="$out/share/php/bar-assistant"

    rm -rf \
      $bar_out/storage \
      $bar_out/bootstrap/cache \
      $bar_out/public/storage \
      $bar_out/public/uploads

    ln -s ${dataDir}/.env                          $bar_out/.env
    ln -s ${dataDir}/storage                       $bar_out/storage
    ln -s ${dataDir}/cache                         $bar_out/bootstrap/cache
    ln -s ${dataDir}/storage/app/public            $bar_out/public/storage
    ln -s ${dataDir}/storage/bar-assistant/uploads $bar_out/public/uploads

    chmod +x $bar_out/artisan
  '';

  passthru.phpPackage = php;

  meta = {
    description = "Self-hosted cocktail bar assistant and recipe manager";
    homepage = "https://barassistant.app";
    changelog = "https://github.com/karlomikus/bar-assistant/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nickthegroot ];
    platforms = lib.platforms.linux;
  };
})
