{ config, ... }:
{
  # == Secrets
  age.secrets.anki-sync-nickthegroot.file = ../../secrets/anki-sync-nickthegroot.age;

  services = {
    anki-sync-server = {
      # Awaiting final setup of NAS - will place/backup files on there
      enable = false;
      port = 27701;
      users = [
        {
          username = "nickthegroot";
          passwordFile = config.age.secrets.anki-sync-nickthegroot.path;
        }
      ];
    };

    caddy.virtualHosts."http://anki-sync.worldline.local".extraConfig = "reverse_proxy localhost:4821";
  };
}
