{ config, ... }:
{
  # == Secrets
  age.secrets.linkwarden.file = ../../secrets/linkwarden.age;

  services.linkwarden = {
    enable = true;
    port = 3640;
    enableRegistration = true;
    environmentFile = config.age.secrets.linkwarden.path;
  };
}
