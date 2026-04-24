{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.bar-assistant;

  bar-assistant = cfg.package.override {
    dataDir = cfg.dataDir;
    includeDefaultData = cfg.includeDefaultData;
  };

  inherit (bar-assistant.passthru) phpPackage;

  appDir = "${bar-assistant}/share/php/bar-assistant";

  artisan = pkgs.writeScriptBin "bar-assistant" ''
    #! ${pkgs.runtimeShell}
    cd "${appDir}"
    sudo=exec
    if [[ "$USER" != ${cfg.user} ]]; then
      sudo='exec /run/wrappers/bin/sudo -u ${cfg.user}'
    fi
    $sudo ${phpPackage}/bin/php artisan "$@"
  '';

  isSecret = v: isAttrs v && v ? _secret && (isString v._secret || builtins.isPath v._secret);

  envVars = lib.generators.toKeyValue {
    mkKeyValue = lib.flip lib.generators.mkKeyValueDefault "=" {
      mkValueString =
        v:
        with builtins;
        if isInt v then
          toString v
        else if isString v then
          "\"${v}\""
        else if true == v then
          "true"
        else if false == v then
          "false"
        else if isSecret v then
          if (isString v._secret) then
            hashString "sha256" v._secret
          else
            hashString "sha256" (builtins.readFile v._secret)
        else
          throw "unsupported type ${typeOf v}: ${(lib.generators.toPretty { }) v}";
    };
  };

  filteredConfig = lib.converge (lib.filterAttrsRecursive (
    _: v:
    !elem v [
      { }
      null
    ]
  )) cfg.config;

  envFile = pkgs.writeText "bar-assistant.env" (envVars filteredConfig);

  secretPaths = lib.mapAttrsToList (_: v: v._secret) (lib.filterAttrs (_: isSecret) cfg.config);

  mkSecretReplacement = file: ''
    replace-secret ${
      escapeShellArgs [
        (
          if (isString file) then
            builtins.hashString "sha256" file
          else
            builtins.hashString "sha256" (builtins.readFile file)
        )
        file
        "${cfg.dataDir}/.env"
      ]
    }
  '';
in
{
  options.services.bar-assistant = {
    enable = mkEnableOption "Bar Assistant cocktail recipe manager";

    package = mkOption {
      type = types.package;
      default = pkgs.bar-assistant;
      description = "The bar-assistant package to use.";
    };

    user = mkOption {
      type = types.str;
      default = "bar-assistant";
      description = "User to run bar-assistant as.";
    };

    group = mkOption {
      type = types.str;
      default = "bar-assistant";
      description = "Group to run bar-assistant as.";
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/bar-assistant";
      description = "Directory for mutable state: .env, storage, bootstrap cache.";
    };

    appKeyFile = mkOption {
      type = types.path;
      description = ''
        File containing the Laravel APP_KEY (base64-encoded 32-byte key).
        Generate with: `head -c 32 /dev/urandom | base64`
      '';
      example = "/run/secrets/bar-assistant-app-key";
    };

    hostName = mkOption {
      type = types.str;
      default = config.networking.fqdnOrHostName;
      defaultText = literalExpression "config.networking.fqdnOrHostName";
      example = "bar.example.com";
      description = "Hostname to serve Bar Assistant on.";
    };

    appURL = mkOption {
      type = types.str;
      default = "https://${cfg.hostName}";
      defaultText = literalExpression ''"https://''${cfg.hostName}"'';
      example = "https://bar.example.com";
      description = "Public URL for Bar Assistant. Caddy provisions HTTPS automatically when hostName is a domain.";
    };

    meilisearch = {
      host = mkOption {
        type = types.str;
        default = "http://127.0.0.1:7700";
        description = "MeiliSearch host URL.";
      };

      keyFile = mkOption {
        type = with types; nullOr path;
        default = null;
        example = "/run/secrets/meilisearch-key";
        description = "File containing the MeiliSearch API key.";
      };
    };

    redis = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Start a local Redis instance (Unix socket) and configure bar-assistant to use it.
          When enabled, `redis.host`, `redis.port`, and `redis.passwordFile` are ignored.
        '';
      };

      host = mkOption {
        type = types.str;
        default = "127.0.0.1";
        description = "Redis host. Ignored when `redis.enable` is true.";
      };

      port = mkOption {
        type = types.port;
        default = 6379;
        description = "Redis port. Ignored when `redis.enable` is true.";
      };

      passwordFile = mkOption {
        type = with types; nullOr path;
        default = null;
        description = "File containing the Redis password. Ignored when `redis.enable` is true.";
      };
    };

    poolConfig = mkOption {
      type =
        with types;
        attrsOf (oneOf [
          str
          int
          bool
        ]);
      default = {
        "pm" = "dynamic";
        "pm.max_children" = 32;
        "pm.start_servers" = 2;
        "pm.min_spare_servers" = 2;
        "pm.max_spare_servers" = 4;
        "pm.max_requests" = 500;
      };
      description = "PHP-FPM pool options for bar-assistant.";
    };

    caddy = {
      extraConfig = mkOption {
        type = types.lines;
        default = "";
        example = "tls /path/to/cert.pem /path/to/key.pem";
        description = "Extra Caddy directives added to the bar-assistant virtual host.";
      };
    };

    includeDefaultData = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Fetch the bar-assistant/data repository and expose it at
        `''${dataDir}/resources/data` as a read-only symlink into the Nix store.
      '';
    };

    config = mkOption {
      type =
        with types;
        attrsOf (
          nullOr (
            either
              (oneOf [
                bool
                int
                port
                path
                str
              ])
              (submodule {
                options._secret = mkOption {
                  type = nullOr (oneOf [
                    str
                    path
                  ]);
                  description = "Path to a file whose contents will be used as the option value.";
                };
              })
          )
        );
      default = { };
      example = literalExpression ''
        {
          MAIL_MAILER = "smtp";
          MAIL_HOST = "smtp.example.com";
          MAIL_PORT = 587;
          ALLOW_REGISTRATION = false;
        }
      '';
      description = ''
        Additional environment variables for bar-assistant's .env file.
        Use `{ _secret = "/path/to/file"; }` for secrets.
      '';
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ artisan ];

    services.redis.servers.bar-assistant = mkIf cfg.redis.enable {
      enable = true;
      user = cfg.user;
      port = 0; # Unix socket only
    };

    services.bar-assistant.config =
      let
        redisSocket = "/run/redis-bar-assistant/redis.sock";
      in
      {
        APP_ENV = "production";
        APP_KEY._secret = cfg.appKeyFile;
        APP_URL = cfg.appURL;

        CACHE_DRIVER = "redis";
        SESSION_DRIVER = "redis";
        QUEUE_CONNECTION = "redis";
        LOG_CHANNEL = "stderr";
        LOG_LEVEL = "warning";

        REDIS_HOST = if cfg.redis.enable then redisSocket else cfg.redis.host;
        REDIS_PORT = if cfg.redis.enable then 0 else cfg.redis.port;
        REDIS_PASSWORD._secret = mkIf (
          !cfg.redis.enable && cfg.redis.passwordFile != null
        ) cfg.redis.passwordFile;

        SCOUT_DRIVER = "meilisearch";
        MEILISEARCH_HOST = cfg.meilisearch.host;
        MEILISEARCH_KEY._secret = mkIf (cfg.meilisearch.keyFile != null) cfg.meilisearch.keyFile;

        DB_CONNECTION = mkDefault "sqlite";
        DB_FOREIGN_KEYS = mkDefault true;
      };

    services.phpfpm.pools.bar-assistant = {
      inherit (cfg) user group;
      phpPackage = phpPackage;
      settings = {
        "listen.mode" = "0660";
        "listen.owner" = cfg.user;
        "listen.group" = config.services.caddy.group;
      }
      // cfg.poolConfig;
    };

    services.caddy = {
      enable = mkDefault true;
      virtualHosts."${cfg.hostName}".extraConfig = ''
        root * ${appDir}/public
        ${cfg.caddy.extraConfig}
        php_fastcgi unix/${config.services.phpfpm.pools."bar-assistant".socket}
        file_server
        encode zstd gzip
      '';
    };

    systemd.services.bar-assistant-setup = {
      description = "Bar Assistant setup (migrations, cache warmup)";
      before = [ "phpfpm-bar-assistant.service" ];
      after = [ "network.target" ] ++ optional cfg.redis.enable "redis-bar-assistant.service";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        User = cfg.user;
        WorkingDirectory = appDir;
      };
      path = [
        pkgs.replace-secret
        artisan
      ];
      script = ''
        set -euo pipefail
        umask 077

        install -T -m 0600 -o ${cfg.user} ${envFile} "${cfg.dataDir}/.env"
        ${concatMapStrings mkSecretReplacement secretPaths}

        if ! grep 'APP_KEY=base64:' "${cfg.dataDir}/.env" >/dev/null; then
          ${pkgs.gnused}/bin/sed -i 's/APP_KEY=/APP_KEY=base64:/' "${cfg.dataDir}/.env"
        fi

        ${lib.getExe artisan} optimize:clear
        ${lib.getExe artisan} migrate --force
        ${lib.getExe artisan} bar:setup-meilisearch || true
        ${lib.getExe artisan} scout:sync-index-settings
        ${lib.getExe artisan} optimize
      '';
    };

    # Laravel Horizon queue worker
    systemd.services.bar-assistant-horizon = {
      description = "Bar Assistant Horizon queue worker";
      after = [
        "network.target"
        "bar-assistant-setup.service"
      ]
      ++ optional cfg.redis.enable "redis-bar-assistant.service";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${phpPackage}/bin/php ${appDir}/artisan horizon";
        Restart = "always";
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = appDir;
        CapabilityBoundingSet = "";
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = "strict";
        ReadOnlyPaths = [ "/" ];
        ReadWritePaths = [ cfg.dataDir ] ++ optional cfg.redis.enable "/run/redis-bar-assistant";
      };
    };

    # Laravel scheduler (every minute)
    systemd.services.bar-assistant-scheduler = {
      description = "Bar Assistant Laravel scheduler";
      after = [ "bar-assistant-setup.service" ];
      serviceConfig = {
        Type = "oneshot";
        User = cfg.user;
        WorkingDirectory = appDir;
        ExecStart = "${phpPackage}/bin/php ${appDir}/artisan schedule:run --no-interaction";
      };
    };

    systemd.timers.bar-assistant-scheduler = {
      description = "Run Bar Assistant Laravel scheduler every minute";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "minutely";
        Persistent = true;
      };
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir}                                    0750 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.dataDir}/bootstrap                          0750 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.dataDir}/cache                              0750 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.dataDir}/storage                            0700 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.dataDir}/storage/app                        0700 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.dataDir}/storage/app/public                 0700 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.dataDir}/storage/bar-assistant              0700 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.dataDir}/storage/bar-assistant/uploads      0700 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.dataDir}/storage/bar-assistant/exports      0700 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.dataDir}/storage/bar-assistant/temp         0700 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.dataDir}/storage/framework                  0700 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.dataDir}/storage/framework/cache            0700 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.dataDir}/storage/framework/sessions         0700 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.dataDir}/storage/framework/views            0700 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.dataDir}/storage/logs                       0700 ${cfg.user} ${cfg.group} - -"
    ];

    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
      home = cfg.dataDir;
    };

    users.users.${config.services.caddy.user}.extraGroups = [ cfg.group ];

    users.groups.${cfg.group} = { };
  };
}
