{
  services = rec {
    jellyfin = {
      enable = true;
      openFirewall = true;
      group = "media";
      # port = 8096 is the default, and can't be easily set in nix
    };
    caddy.virtualHosts."jellyfin.home.nickthegroot.com".extraConfig = "reverse_proxy localhost:8096";

    komga = {
      enable = true;
      settings.server.port = 8097;
      openFirewall = true;
      group = "media";
    };
    caddy.virtualHosts."komga.home.nickthegroot.com".extraConfig =
      "reverse_proxy localhost:${toString komga.settings.server.port}";

    immich = {
      enable = true;
      port = 2283;
      mediaLocation = "/mnt/media-sensitive/photos";
      group = "media";
    };
    caddy.virtualHosts."photos.home.nickthegroot.com".extraConfig =
      "reverse_proxy localhost:${toString immich.port}";
  };
}
