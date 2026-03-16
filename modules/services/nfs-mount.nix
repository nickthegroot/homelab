{
  config,
  lib,
  ...
}:

with lib;

let
  cfg = config.services.nfs-mount;

  automountOpts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
in
{
  options.services.nfs-mount = {
    enable = mkEnableOption "Mount NFS shares";

    host = mkOption {
      type = types.str;
      description = "Hostname or IP address of the NFS server.";
      example = "nas.local";
    };

    shares = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = ''
        Attribute set mapping local mount points to NFS export paths.
        Each key is the absolute path where the share will be mounted;
        each value is the exported path on the server.
      '';
      example = literalExpression ''
        {
          "/mnt/media" = "/export/media";
          "/mnt/backups" = "/export/backups";
        }
      '';
    };
  };

  config = mkIf cfg.enable {
    boot.supportedFilesystems = [ "nfs" ];

    fileSystems = mapAttrs (mountPoint: exportPath: {
      device = "${cfg.host}:${exportPath}";
      fsType = "nfs";
      options = [ automountOpts ];
    }) cfg.shares;
  };
}
