{ config, ... }:
{
  age.secrets.anki-sync-nickthegroot.file = ../../secrets/anki-sync-nickthegroot.age;

  services = rec {
    anki-sync-user = {
      enable = true;
      port = 27701;
      baseDirectory = "/mnt/hosting/anki-sync";

      users = [
        {
          username = "nickthegroot";
          passwordFile = config.age.secrets.anki-sync-nickthegroot.path;
        }
      ];
    };

    caddy.virtualHosts."anki-sync.home.nickthegroot.com".extraConfig =
      "reverse_proxy localhost:${toString anki-sync-user.port}";
  };

  systemd.services.anki-sync-user = {
    requires = [ "mnt-hosting.mount" ];
    after = [ "mnt-hosting.mount" ];
  };
}
