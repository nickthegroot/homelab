inputs:
let
  port = 5678;
in
{
  services = {
    glance = {
      enable = true;
      environmentFile = "/var/lib/secrets/glance-env";
      settings = {
        server.port = port;

        # https://github.com/glanceapp/glance/blob/main/docs/themes.md#catppuccin-mocha
        theme = {
          background-color = "240 21 15";
          contrast-multiplier = 1.2;
          primary-color = "217 92 83";
          positive-color = "115 54 76";
          negative-color = "347 70 65";
        };

        pages = [
          (import ./pages/home.nix inputs)
        ];
      };
    };
  };

  services.caddy.virtualHosts."http://dash.worldline.local".extraConfig =
    "reverse_proxy localhost:${toString port}";
}
