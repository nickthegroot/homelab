{ config, ... }:
{
  age.secrets.hashida-itaru-nas-account.file = ../../secrets/hashida-itaru-nas-account.age;

  services.nas-mount = {
    enable = true;
    host = "192.168.1.10";
    secretsFile = config.age.secrets.hashida-itaru-nas-account.path;

    shares = {
      "/mnt/media" = "media";
      "/mnt/media-sensitive" = "media-sensitive";
      "/mnt/hosting" = "hosting";
    };
  };
}
