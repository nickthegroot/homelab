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

    caddy.virtualHosts."http://anki-sync.worldline.local".extraConfig =
      "reverse_proxy localhost:${toString anki-sync-user.port}";
  };

  users.users.anki-sync.extraGroups = [ "nas-users" ];
}
