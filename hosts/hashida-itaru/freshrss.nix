{
  services = {
    freshrss = rec {
      enable = true;
      webserver = "caddy";
      baseUrl = "http://rss.worldline.local";
      virtualHost = baseUrl;
      passwordFile = "/var/lib/secrets/freshrss-password";
    };
  };
}
