{ config, ... }:
{
  age.secrets.anki-sync-nickthegroot.file = ../../secrets/anki-sync-nickthegroot.age;
  services.anki-sync-server = {
    enable = true;
    port = 27701;
    baseDirectory = "/mnt/media/anki";
    users = [
      {
        username = "nickthegroot";
        passwordFile = config.age.secrets.anki-sync-nickthegroot.path;
      }
    ];
  };
}
