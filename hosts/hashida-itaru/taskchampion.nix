{
  services = rec {
    taskchampion-sync-server = {
      enable = true;
      port = 10222;
    };

    caddy.virtualHosts."taskchampion.home.nickthegroot.com".extraConfig =
      "reverse_proxy localhost:${toString taskchampion-sync-server.port}";
  };
}
