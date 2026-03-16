{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.smb-mount;

  automountOpts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
in
{
  options.services.smb-mount = {
    enable = mkEnableOption "Mount SMB/CIFS shares";

    host = mkOption {
      type = types.str;
      description = "Hostname or IP address of the SMB server.";
      example = "nas.local";
    };

    # https://nixos.wiki/wiki/Samba#Samba_Client
    secretsFile = mkOption {
      type = types.path;
      description = ''
        Path to a credentials file used for CIFS authentication.
        The file should contain lines of the form:
          username=...
          password=...
      '';
      example = "/run/secrets/smb-credentials";
    };

    shares = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = ''
        Attribute set mapping local mount points to SMB share names.
        Each key is the absolute path where the share will be mounted;
        each value is the name of the share on the server.
      '';
      example = literalExpression ''
        {
          "/mnt/media" = "media";
          "/mnt/backups" = "backups";
        }
      '';
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.cifs-utils ];

    services.samba = {
      enable = true;
      openFirewall = true;
    };

    fileSystems = mapAttrs (mountPoint: shareName: {
      device = "//${cfg.host}/${shareName}";
      fsType = "cifs";
      options = [ "${automountOpts},credentials=${cfg.secretsFile}" ];
    }) cfg.shares;
  };
}
