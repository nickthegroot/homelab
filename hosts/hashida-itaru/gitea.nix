let
  port = 8152;
  domain = "git.home.nickthegroot.com";
in
{
  services = {
    gitea = {
      enable = true;
      settings.server = {
        DOMAIN = domain;
        ROOT_URL = "https://${domain}";
        HTTP_PORT = port;
      };
    };

    caddy.virtualHosts."${domain}".extraConfig = "reverse_proxy localhost:${toString port}";
  };
}
