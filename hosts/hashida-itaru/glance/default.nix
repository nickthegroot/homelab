{ glance-anki, config, ... }@inputs:
let
  port = 5678;
in
{
  imports = [ glance-anki.nixosModules.default ];

  services = {
    glance = {
      enable = true;
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

    glance-anki = {
      enable = true;
      group = "anki-sync";

      collectionPath = "${config.services.anki-sync-user.baseDirectory}/nickthegroot/collection.anki2";
      port = 8239;
    };
  };

  services.caddy.virtualHosts."http://dash.worldline.local".extraConfig =
    "reverse_proxy localhost:${toString port}";
}
