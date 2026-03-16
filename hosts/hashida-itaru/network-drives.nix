{
  services = {
    nfs-mount = {
      enable = true;
      host = "192.168.1.10";

      shares = {
        "/mnt/media" = "/mnt/user/media";
        "/mnt/media-sensitive" = "/mnt/user/media-sensitive";
        "/mnt/hosting" = "/mnt/user/hosting";
      };
    };
  };
}
