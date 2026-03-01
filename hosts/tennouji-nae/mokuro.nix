{
  services = {
    mokuro-reader = {
      enable = true;
      port = 4821;
    };

    mokuro-bunko = rec {
      enable = true;
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
  };
}
