{
  services = rec {
    open-webui = {
      enable = true;
      port = 2000;
    };

    caddy.virtualHosts."http://ai.worldline.local".extraConfig =
      "reverse_proxy localhost:${toString open-webui.port}";
  };
}
