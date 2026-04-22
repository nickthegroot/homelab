let
  port = 8152;
  domain = "git.worldline.local";
in
{
  services = {
    gitea = {
      enable = true;
      settings.server = {
        DOMAIN = domain;
        ROOT_URL = "http://${domain}";
        HTTP_PORT = port;
      };
    };

    caddy.virtualHosts."http://${domain}".extraConfig = "reverse_proxy localhost:${toString port}";
  };
}
