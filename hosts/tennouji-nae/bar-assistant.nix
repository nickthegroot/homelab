{
  pkgs,
  lib,
  config,
  ...
}:
let
  HOSTNAME = "bar-assistant.worldline.local";
  BASE_URL = "http://${HOSTNAME}";
  MEILISEARCH_URL = "${BASE_URL}/search";
  API_URL = "${BASE_URL}/bar";
  MEILI_NO_ANALYTICS = "true";
  MEILI_ENV = "production";
  MEILISEARCH_HOST = "http://meilisearch:7700";
  REDIS_HOST = "redis";
  REDIS_ALLOW_EMPTY_PASSWORD = "yes";
  CACHE_DRIVER = "redis";
  SESSION_DRIVER = "redis";
  ALLOW_REGISTRATION = "false";

  SERVER_PORT = "9000";
  SEARCH_PORT = "9001";
  FRONTEND_PORT = "9002";

  serverEnv = {
    APP_URL = API_URL;
    inherit
      MEILISEARCH_HOST
      REDIS_HOST
      CACHE_DRIVER
      SESSION_DRIVER
      ;
  };
  frontenvEnv = {
    inherit
      API_URL
      MEILISEARCH_URL
      ALLOW_REGISTRATION
      ;
  };
  meilisearchEnv = {
    inherit
      MEILI_ENV
      MEILI_NO_ANALYTICS
      ;
  };
  redisEnv = {
    "ALLOW_EMPTY_PASSWORD" = REDIS_ALLOW_EMPTY_PASSWORD;
  };

  secretsFile = config.age.secrets.bar-assistant.path;
in
{
  # == Secrets
  age.secrets.bar-assistant.file = ../../secrets/bar-assistant.age;

  # == Containers

  # === Server
  virtualisation.oci-containers.containers."bar-assistant-bar-assistant" = {
    image = "barassistant/server:v5";
    environmentFiles = [ secretsFile ];
    environment = serverEnv;
    ports = [ "127.0.0.1:${SERVER_PORT}:8080/tcp" ];
    volumes = [
      "bar-assistant_bar_data:/var/www/cocktails/storage/bar-assistant:rw"
    ];
    dependsOn = [
      "bar-assistant-meilisearch"
      "bar-assistant-redis"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=bar-assistant"
      "--network=bar-assistant_default"
    ];
  };
  systemd.services."podman-bar-assistant-bar-assistant" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-bar-assistant_default.service"
      "podman-volume-bar-assistant_bar_data.service"
    ];
    requires = [
      "podman-network-bar-assistant_default.service"
      "podman-volume-bar-assistant_bar_data.service"
    ];
    partOf = [
      "podman-compose-bar-assistant-root.target"
    ];
    wantedBy = [
      "podman-compose-bar-assistant-root.target"
    ];
  };

  # === Search
  virtualisation.oci-containers.containers."bar-assistant-meilisearch" = {
    image = "getmeili/meilisearch:v1.12";
    environmentFiles = [ secretsFile ];
    environment = meilisearchEnv;
    ports = [ "127.0.0.1:${SEARCH_PORT}:7700/tcp" ];
    volumes = [
      "bar-assistant_meilisearch_data:/meili_data:rw"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=meilisearch"
      "--network=bar-assistant_default"
    ];
  };
  systemd.services."podman-bar-assistant-meilisearch" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-bar-assistant_default.service"
      "podman-volume-bar-assistant_meilisearch_data.service"
    ];
    requires = [
      "podman-network-bar-assistant_default.service"
      "podman-volume-bar-assistant_meilisearch_data.service"
    ];
    partOf = [
      "podman-compose-bar-assistant-root.target"
    ];
    wantedBy = [
      "podman-compose-bar-assistant-root.target"
    ];
  };

  # === Redis
  virtualisation.oci-containers.containers."bar-assistant-redis" = {
    image = "redis";
    environment = redisEnv;
    log-driver = "journald";
    extraOptions = [
      "--network-alias=redis"
      "--network=bar-assistant_default"
    ];
  };
  systemd.services."podman-bar-assistant-redis" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-bar-assistant_default.service"
    ];
    requires = [
      "podman-network-bar-assistant_default.service"
    ];
    partOf = [
      "podman-compose-bar-assistant-root.target"
    ];
    wantedBy = [
      "podman-compose-bar-assistant-root.target"
    ];
  };

  # === Frontend
  virtualisation.oci-containers.containers."bar-assistant-salt-rim" = {
    image = "barassistant/salt-rim:v4";
    environment = frontenvEnv;
    ports = [ "127.0.0.1:${FRONTEND_PORT}:8080/tcp" ];
    dependsOn = [
      "bar-assistant-bar-assistant"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=salt-rim"
      "--network=bar-assistant_default"
    ];
  };
  systemd.services."podman-bar-assistant-salt-rim" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-bar-assistant_default.service"
    ];
    requires = [
      "podman-network-bar-assistant_default.service"
    ];
    partOf = [
      "podman-compose-bar-assistant-root.target"
    ];
    wantedBy = [
      "podman-compose-bar-assistant-root.target"
    ];
  };

  # == Networks
  systemd.services."podman-network-bar-assistant_default" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "podman network rm -f bar-assistant_default";
    };
    script = ''
      podman network inspect bar-assistant_default || podman network create bar-assistant_default
    '';
    partOf = [ "podman-compose-bar-assistant-root.target" ];
    wantedBy = [ "podman-compose-bar-assistant-root.target" ];
  };

  # == Volumes
  systemd.services."podman-volume-bar-assistant_bar_data" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman volume inspect bar-assistant_bar_data || podman volume create bar-assistant_bar_data
    '';
    partOf = [ "podman-compose-bar-assistant-root.target" ];
    wantedBy = [ "podman-compose-bar-assistant-root.target" ];
  };
  systemd.services."podman-volume-bar-assistant_meilisearch_data" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman volume inspect bar-assistant_meilisearch_data || podman volume create bar-assistant_meilisearch_data
    '';
    partOf = [ "podman-compose-bar-assistant-root.target" ];
    wantedBy = [ "podman-compose-bar-assistant-root.target" ];
  };

  # == Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."podman-compose-bar-assistant-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = [ "multi-user.target" ];
  };

  # == Reverse Proxy
  networking.firewall = {
    allowedTCPPorts = [ 80 ];
  };

  # https://github.com/bar-assistant/docker/blob/0b3724efa5ed17e7224a027f6b9777579b85db84/nginx.conf
  services.nginx = {
    enable = true;

    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;

    virtualHosts = {
      ${HOSTNAME} = {
        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:${FRONTEND_PORT}";
          };
          "/bar/" = {
            proxyPass = "http://127.0.0.1:${SERVER_PORT}/";
            extraConfig = ''
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
            '';
          };
          "/search/" = {
            proxyPass = "http://127.0.0.1:${SEARCH_PORT}/";
            extraConfig = ''
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
            '';
          };

          "= /favicon.ico" = {
            extraConfig = ''
              access_log off;
              log_not_found off;
            '';
          };
          "= /robots.txt" = {
            extraConfig = ''
              access_log off;
              log_not_found off;
            '';
          };
        };
      };
    };
  };
}
