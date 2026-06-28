{
  services = rec {
    open-webui = {
      enable = true;
      port = 2000;
    };

    caddy.virtualHosts."ai.home.nickthegroot.com".extraConfig =
      "reverse_proxy localhost:${toString open-webui.port}";
  };
}
