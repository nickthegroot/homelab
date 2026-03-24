{ pkgs, ... }:
let
  catppuccinTheme = pkgs.fetchurl {
    url = "https://github.com/catppuccin/home-assistant/releases/download/v2.1.2/catppuccin.yaml";
    hash = "sha256:1e83da26415a8d34ace827588668ea3a579d2d99feccddbd43751055b9229522";
  };

  themesDir = pkgs.runCommand "home-assistant-themes" { } ''
    mkdir -p $out
    cp ${catppuccinTheme} $out/catppuccin.yaml
  '';
in
{
  services = rec {
    # https://wiki.nixos.org/wiki/Home_Assistant
    home-assistant = {
      enable = true;
      extraComponents = [
        "radio_browser"
        "shopping_list"
        "nws"

        "mqtt"
        "nest"
        "tesla_wall_connector"
      ];

      config = {
        default_config = { };
        homeassistant = {
          name = "DeGroot Home";
          unit_system = "metric";
        };

        http = {
          server_port = 8123;
          server_host = "::1";
          trusted_proxies = [ "::1" ];
          use_x_forwarded_for = true;
        };

        frontend = {
          themes = "!include_dir_merge_named ${themesDir}";
        };
      };
    };

    govee2mqtt = {
      enable = true;
      environmentFile = "/var/lib/secrets/govee2mqtt";
    };

    mosquitto = {
      enable = true;
      listeners = [
        {
          acl = [ "pattern readwrite #" ];
          port = 1883;
          omitPasswordAuth = true;
          settings.allow_anonymous = true;
        }
      ];
    };

    caddy.virtualHosts."http://home.worldline.local".extraConfig =
      "reverse_proxy localhost:${toString home-assistant.config.http.server_port}";
  };
}
