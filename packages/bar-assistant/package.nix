{
  lib,
  dataDir ? "/var/lib/bar-assistant",
  includeDefaultData ? true,
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

  defaultData = fetchFromGitHub {
    owner = "bar-assistant";
    repo = "data";
    rev = "0d71544764b78e6c25adad197ed02eeb1d1ec7ee";
    hash = "sha256-0HCkNJpc1Qnif+xB5yDyiEoSJHHeRvxwOsNA/hrgDe0=";
  };
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
  ''
  + lib.optionalString includeDefaultData ''
    ln -s ${defaultData} $bar_out/resources/data
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
