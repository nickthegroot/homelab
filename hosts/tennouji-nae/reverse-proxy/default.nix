{ lib, ... }:
{
  services.nginx.enable = lib.mkForce false;

  services.caddy = {
    enable = true;
    configFile = ./Caddyfile;
  };

  networking.firewall = {
    allowedTCPPorts = [
      80
      443
    ];
  };
}
