{
  services = rec {
    taskchampion-sync-server = {
      enable = true;
      port = 10222;
    };

    caddy.virtualHosts."http://taskchampion.worldline.local".extraConfig =
      "reverse_proxy localhost:${toString taskchampion-sync-server.port}";
  };
}
