{
  services = {
    mokuro-reader = {
      enable = true;
      port = 4821;
      group = "media";
    };
    caddy.virtualHosts."mokuro.home.nickthegroot.com".extraConfig = "reverse_proxy localhost:4821";
  };
}
