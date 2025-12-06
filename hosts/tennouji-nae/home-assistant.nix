{
  services = {
    home-assistant = {
      enable = true;
      # https://www.home-assistant.io/integrations
      extraComponents = [
        "apple_tv"
        "govee_light_local"
        "matter"
        "nest"
        "tesla_wall_connector"
        "unifi"
      ];
      config = {
        default_config = { };
        http = {
          server_host = "::1";
          trusted_proxies = [ "::1" ];
          use_x_forwarded_for = true;
        };
      };
    };

    matter-server.enable = true;
  };
}
