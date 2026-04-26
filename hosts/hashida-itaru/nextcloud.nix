{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.services.nextcloud;
  fpm = config.services.phpfpm.pools.nextcloud;
in
{
  services = {
    nextcloud = {
      enable = true;
      package = pkgs.nextcloud33;
      hostName = "cloud.worldline.local";

      config = {
        adminpassFile = "/var/lib/secrets/nextcloud-admin-pass";
        dbtype = "sqlite";
      };
    };

    # Nginx -> Caddy
    phpfpm.pools.nextcloud.settings = {
      "listen.owner" = config.services.caddy.user;
      "listen.group" = config.services.caddy.group;
    };

    caddy.virtualHosts."http://${cfg.hostName}".extraConfig = ''
      encode zstd gzip

      root * ${config.services.nginx.virtualHosts.${cfg.hostName}.root}

      # DavClnt user-agent redirect at root (mirrors nginx `= /` location)
      @davclnt {
        path /
        header User-Agent DavClnt*
      }
      redir @davclnt /remote.php/webdav{query} 302

      # Well-known redirects, excluding ACME challenge and PKI validation paths
      redir /.well-known/carddav /remote.php/dav/ 301
      redir /.well-known/caldav /remote.php/dav/ 301
      @wellknown {
        path /.well-known/*
        not path /.well-known/acme-challenge/*
        not path /.well-known/pki-validation/*
      }
      redir @wellknown /index.php{uri} 301

      # Remote redirect (prefix match: /remote, /remote/, /remote/*)
      redir /remote /remote.php{uri} 301
      redir /remote/* /remote.php{uri} 301

      header {
        X-Content-Type-Options nosniff
        X-Robots-Tag "noindex, nofollow"
        X-Permitted-Cross-Domain-Policies none
        X-Frame-Options SAMEORIGIN
        Referrer-Policy no-referrer
        ${lib.optionalString cfg.https ''
          Strict-Transport-Security "max-age=${toString cfg.nginx.hstsMaxAge}; includeSubDomains"
        ''}-X-Powered-By
        -Referrer-Policy
        -X-Content-Type-Options
        -X-Frame-Options
        -X-Permitted-Cross-Domain-Policies
        -X-Robots-Tag
      }

      @forbidden {
        path /build/* /tests/* /config/* /lib/* /3rdparty/* /templates/* /data/*
        path /.* /autotest* /occ* /issue* /indie* /db_* /console*
        not path /.well-known/*
      }
      error @forbidden 404

      # Static assets — serve file if present, else fall back to index.php
      @static path *.css *.js *.mjs *.svg *.gif *.ico *.jpg *.jpeg *.png *.webp *.wasm *.tflite *.map *.html *.ttf *.bcmap *.mp4 *.webm *.ogg *.flac
      handle @static {
        header Cache-Control "max-age=15778463"
        try_files {path} /index.php{uri}
        file_server
      }

      # Updater and OCS provider directories
      @updater path /updater /updater/* /ocs-provider /ocs-provider/*
      handle @updater {
        try_files {path}/ =404
        file_server
      }

      php_fastcgi unix/${fpm.socket} {
        root ${config.services.nginx.virtualHosts.${cfg.hostName}.root}
        env front_controller_active true
        env modHeadersAvailable true
        env HTTPS ${if cfg.https then "on" else "off"}
        read_timeout ${toString cfg.fastcgiTimeout}s
      }

      file_server
    '';
  };

  users.groups.nextcloud.members = [
    "nextcloud"
    config.services.caddy.user
  ];
}
