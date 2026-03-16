{
  services = rec {
    jellyfin = {
      enable = true;
      openFirewall = true;
      # port = 8096 is the default, and can't be easily set in nix
    };
    caddy.virtualHosts."http://jellyfin.worldline.local".extraConfig = "reverse_proxy localhost:8096";

    komga = {
      enable = true;
      settings.server.port = 8097;
      openFirewall = true;
    };
    caddy.virtualHosts."http://komga.worldline.local".extraConfig =
      "reverse_proxy localhost:${toString komga.settings.server.port}";

    immich = {
      enable = true;
      port = 2283;
      mediaLocation = "/mnt/media-sensitive/photos";
    };
    caddy.virtualHosts."http://photos.worldline.local".extraConfig =
      "reverse_proxy localhost:${toString immich.port}";
  };
}
