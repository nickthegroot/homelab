{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
}:

buildHomeAssistantComponent rec {
  owner = "tabascoz";
  domain = "neakasa";
  version = "1.4.1";

  src = fetchFromGitHub {
    inherit owner;
    repo = "hass-neakasa";
    tag = "v${version}";
    hash = "sha256-JINaML6lJEcGvw8K2h91Ig35BCCHHU+hVpCttzf/X1U=";
  };

  meta = {
    description = "Neakasa (M1 cat litter box) integration for Home Assistant";
    homepage = "https://github.com/tabascoz/hass-neakasa";
    changelog = "https://github.com/tabascoz/hass-neakasa/releases/tag/v${version}";
    license = lib.licenses.mit;
  };
}
