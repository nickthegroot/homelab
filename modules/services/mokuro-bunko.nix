{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.mokuro-bunko;
  yamlFormat = pkgs.formats.yaml { };
in
{
  options.services.mokuro-bunko = {
    enable = mkEnableOption "mokuro-bunko server";

    package = mkOption {
      type = types.package;
      default = pkgs.mokuro-bunko;
      description = "The mokuro-bunko package to use.";
    };

    settings = mkOption {
      inherit (yamlFormat) type;
      default = { };
      description = ''
        Mokuro Bunko configuration. See the upstream documentation for available options.
      '';
      example = {
        server = {
          host = "0.0.0.0";
          port = 8080;
        };
        storage.base_path = "/var/lib/mokuro-bunko";
        registration.mode = "self";
      };
    };
  };

  config = mkIf cfg.enable {
    # Default settings merged with user settings
    services.mokuro-bunko.settings = {
      server = mkDefault {
        host = "0.0.0.0";
        port = 8080;
      };
      storage = mkDefault {
        base_path = "/var/lib/mokuro-bunko";
      };
      registration = mkDefault {
        mode = "self";
        default_role = "registered";
        allow_anonymous_browse = true;
        allow_anonymous_download = true;
      };
      cors = mkDefault {
        enabled = true;
        allowed_origins = [
          "https://reader.mokuro.app"
          "http://localhost:5173"
          "http://localhost:*"
          "http://127.0.0.1:*"
        ];
        allow_credentials = true;
      };
      ssl = mkDefault {
        enabled = false;
        auto_cert = false;
      };
      admin = mkDefault {
        enabled = true;
        path = "/_admin";
      };
      catalog = mkDefault {
        enabled = false;
        reader_url = "https://reader.mokuro.app";
        use_as_homepage = false;
      };
      queue = mkDefault {
        show_in_nav = false;
        public_access = true;
      };
      # ocr = mkDefault {
      #   backend = "auto";
      #   poll_interval = 30;
      # };
    };

    systemd.services.mokuro-bunko = {
      description = "Mokuro Bunko Server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        # TODO: add ocr support
        # Will need to figure out how to handle the custom venv it tries to create
        #   Relevant: https://github.com/Gnathonic/mokuro-bunko/blob/693b9cc52abaeeb6bab6833399d8bd44b2fa705b/src/mokuro_bunko/ocr/installer.py#L318-L320
        ExecStart = "${cfg.package}/bin/mokuro-bunko --config ${yamlFormat.generate "mokuro-bunko-config.yaml" cfg.settings} serve --ocr skip";
        Restart = "always";
        User = "mokuro-bunko";
        Group = "mokuro-bunko";
        StateDirectory = "mokuro-bunko";
        WorkingDirectory = "/var/lib/mokuro-bunko";
        CapabilityBoundingSet = "";
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = "strict";
        ReadOnlyPaths = [ "/" ];
        ReadWritePaths = [ "/var/lib/mokuro-bunko" ];
      };
    };

    users.users.mokuro-bunko = {
      isSystemUser = true;
      group = "mokuro-bunko";
      home = "/var/lib/mokuro-bunko";
    };

    users.groups.mokuro-bunko = { };
  };
}
