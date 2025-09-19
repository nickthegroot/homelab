{ config, ... }:
{
  # == Secrets
  age.secrets.anki-sync-nickthegroot.file = ../../secrets/anki-sync-nickthegroot.age;

  # == Overlay
  imports = [
    ./modules/anki-sync-server-user.nix
  ];

  services.anki-sync-server-user = {
    enable = true;
    port = 27701;
    users = [
      {
        username = "nickthegroot";
        passwordFile = config.age.secrets.anki-sync-nickthegroot.path;
      }
    ];
  };
}
