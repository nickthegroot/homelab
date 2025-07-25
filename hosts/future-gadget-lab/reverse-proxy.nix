{ config, ... }:
{
  # == Secrets
  age.secrets.caddy = {
    file = ../../secrets/caddy.age;
    owner = config.services.caddy.user;
    group = config.services.caddy.group;
  };

  services.caddy = {
    enable = true;
    configFile = config.age.secrets.caddy.path;
  };
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
