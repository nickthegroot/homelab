{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.salt-rim;

  # Runtime config injected as /config.js — read by the SPA via window.srConfig
  configJs = pkgs.writeText "salt-rim-config.js" ''
    window.srConfig = ${builtins.toJSON cfg.settings};
  '';
in
{
  options.services.salt-rim = {
    enable = mkEnableOption "Salt Rim Bar Assistant web client";

    package = mkOption {
      type = types.package;
      default = pkgs.salt-rim;
      description = "The salt-rim package to use.";
    };

    hostName = mkOption {
      type = types.str;
      default = config.networking.fqdnOrHostName;
      defaultText = literalExpression "config.networking.fqdnOrHostName";
      example = "bar-ui.example.com";
      description = "Hostname to serve Salt Rim on.";
    };

    settings = mkOption {
      type = types.submodule {
        freeformType = (pkgs.formats.json { }).type;
        options = {
          API_URL = mkOption {
            type = types.str;
            example = "https://bar-api.example.com";
            description = "URL of the Bar Assistant API.";
          };
          MEILISEARCH_URL = mkOption {
            type = with types; nullOr str;
            default = null;
            example = "https://search.example.com";
            description = "URL of the MeiliSearch instance. When null, falls back to the API server origin.";
          };
        };
      };
      default = { };
      description = ''
        Contents of the runtime `config.js` exposed as `window.srConfig`.
        See upstream documentation for available keys:
        `API_URL`, `MEILISEARCH_URL`, `DEFAULT_LOCALE`, `ALLOW_REGISTRATION`, etc.
      '';
    };

    caddy = {
      extraConfig = mkOption {
        type = types.lines;
        default = "";
        example = "tls /path/to/cert.pem /path/to/key.pem";
        description = "Extra Caddy directives added to the Salt Rim virtual host.";
      };
    };
  };

  config = mkIf cfg.enable {
    services.caddy = {
      enable = mkDefault true;
      virtualHosts."${cfg.hostName}".extraConfig = ''
        encode zstd gzip
        ${cfg.caddy.extraConfig}

        # Long-lived cache for hashed assets, no-cache for entry points
        @hashed path_regexp \.(js|css|woff2?|ttf|eot|png|jpg|jpeg|gif|ico|svg)$
        header @hashed Cache-Control "public, max-age=31536000, immutable"
        header /index.html Cache-Control "no-cache, no-store, must-revalidate"

        # Inject runtime config — must be a handle block so it takes
        # priority over the SPA fallback handle below
        handle /config.js {
          root * ${builtins.dirOf configJs}
          rewrite * /${builtins.baseNameOf configJs}
          file_server
        }

        # SPA fallback
        handle {
          root * ${cfg.package}
          try_files {path} /index.html
          file_server
        }
      '';
    };
  };
}
