{
  services = {
    freshrss = rec {
      enable = true;
      webserver = "caddy";
      baseUrl = "https://rss.home.nickthegroot.com";
      virtualHost = baseUrl;
      passwordFile = "/var/lib/secrets/freshrss-password";
    };
  };
}
