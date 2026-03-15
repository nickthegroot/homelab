{ lib, ... }:
{
  services.nginx.enable = lib.mkForce false;
  services.caddy.enable = true;

  networking.firewall = {
    allowedTCPPorts = [
      80
      443
    ];
  };
}
