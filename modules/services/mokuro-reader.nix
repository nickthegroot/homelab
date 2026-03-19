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

    user = mkOption {
      type = types.str;
      default = "mokuro-reader";
      description = "User to run the mokuro-reader service as.";
    };

    group = mkOption {
      type = types.str;
      default = "mokuro-reader";
      description = "Group to run the mokuro-reader service as.";
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
        User = cfg.user;
        Group = cfg.group;
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

    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
      home = "/var/lib/mokuro-reader";
    };

    users.groups.${cfg.group} = { };
  };
}
