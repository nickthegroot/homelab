{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.mokuro-reader;
in
{
  options.services.mokuro-reader = {
    enable = mkEnableOption "mokuro-reader server";

    package = mkOption {
      type = types.package;
      default = pkgs.mokuro-reader;
      description = "The mokuro-reader package to use.";
    };

    port = mkOption {
      type = types.port;
      default = 3000;
      description = "The port the server will listen on.";
    };

    host = mkOption {
      type = types.str;
      default = "0.0.0.0";
      description = "The host the server will listen on.";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.mokuro-reader = {
      description = "Mokuro Reader Server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      environment = {
        PORT = toString cfg.port;
        HOST = cfg.host;
      };

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/mokuro-reader";
        Restart = "always";
        User = "mokuro-reader";
        Group = "mokuro-reader";
        StateDirectory = "mokuro-reader";
        WorkingDirectory = "/var/lib/mokuro-reader";
        CapabilityBoundingSet = "";
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = "strict";
        ReadOnlyPaths = [ "/" ];
        ReadWritePaths = [ "/var/lib/mokuro-reader" ];
      };
    };

    users.users.mokuro-reader = {
      isSystemUser = true;
      group = "mokuro-reader";
      home = "/var/lib/mokuro-reader";
    };

    users.groups.mokuro-reader = { };
  };
}
