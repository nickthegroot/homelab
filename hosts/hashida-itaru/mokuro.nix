{
  services = {
    mokuro-reader = {
      enable = true;
      port = 4821;
      group = "media";
    };
    caddy.virtualHosts."http://mokuro.worldline.local".extraConfig = "reverse_proxy localhost:4821";

    mokuro-bunko = rec {
      enable = true;
      group = "media";
      settings = {
        server.port = 4822;
        catalog.reader_url = "http://mokuro.worldline.local";
        cors.allowed_origins = [
          settings.catalog.reader_url
          "https://reader.mokuro.app"
          "http://localhost:*"
        ];
      };
    };
    caddy.virtualHosts."http://mokuro-bunko.worldline.local".extraConfig =
      "reverse_proxy localhost:4822";
  };
}
