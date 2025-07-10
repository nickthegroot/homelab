{
  pkgs,
  lib,
  config,
  ...
}:
let
  # Modified from compose2nix
  POSTGRES_DB = "maybe_production";
  POSTGRES_USER = "maybe_user";
  DB_HOST = "db";
  DB_PORT = "5432";
  RAILS_ASSUME_SSL = "false";
  RAILS_FORCE_SSL = "false";
  REDIS_URL = "redis://redis:6379/1";
  SELF_HOSTED = "true";
  PORT = "3000";

  secretsFile = config.age.secrets.maybe-finance.path;
  dbEnv = {
    inherit POSTGRES_DB POSTGRES_USER;
  };
  appEnv = dbEnv // {
    inherit
      DB_HOST
      DB_PORT
      RAILS_ASSUME_SSL
      RAILS_FORCE_SSL
      REDIS_URL
      SELF_HOSTED
      ;
  };
in
{
  # == Secrets
  age.secrets.maybe-finance.file = ../../secrets/maybe-finance.age;

  # == Containers

  # === Database
  virtualisation.oci-containers.containers."maybe-db" = {
    image = "postgres:16";
    environment = dbEnv;
    environmentFiles = [ secretsFile ];
    volumes = [
      "maybe_postgres-data:/var/lib/postgresql/data:rw"
    ];
    log-driver = "journald";
    extraOptions = [
      "--health-cmd=pg_isready -U $POSTGRES_USER -d $POSTGRES_DB"
      "--health-interval=5s"
      "--health-retries=5"
      "--health-timeout=5s"
      "--network-alias=db"
      "--network=maybe_maybe_net"
    ];
  };
  systemd.services."podman-maybe-db" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-maybe_maybe_net.service"
      "podman-volume-maybe_postgres-data.service"
    ];
    requires = [
      "podman-network-maybe_maybe_net.service"
      "podman-volume-maybe_postgres-data.service"
    ];
    partOf = [
      "podman-compose-maybe-root.target"
    ];
    wantedBy = [
      "podman-compose-maybe-root.target"
    ];
  };

  # === Redis
  virtualisation.oci-containers.containers."maybe-redis" = {
    image = "redis:latest";
    volumes = [
      "maybe_redis-data:/data:rw"
    ];
    log-driver = "journald";
    extraOptions = [
      "--health-cmd=[\"redis-cli\", \"ping\"]"
      "--health-interval=5s"
      "--health-retries=5"
      "--health-timeout=5s"
      "--network-alias=redis"
      "--network=maybe_maybe_net"
    ];
  };
  systemd.services."podman-maybe-redis" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-maybe_maybe_net.service"
      "podman-volume-maybe_redis-data.service"
    ];
    requires = [
      "podman-network-maybe_maybe_net.service"
      "podman-volume-maybe_redis-data.service"
    ];
    partOf = [
      "podman-compose-maybe-root.target"
    ];
    wantedBy = [
      "podman-compose-maybe-root.target"
    ];
  };

  # === Web Application
  virtualisation.oci-containers.containers."maybe-web" = {
    image = "ghcr.io/maybe-finance/maybe:latest";
    environment = appEnv;
    environmentFiles = [ secretsFile ];
    volumes = [
      "maybe_app-storage:/rails/storage:rw"
    ];
    ports = [
      "${PORT}:3000/tcp"
    ];
    dependsOn = [
      "maybe-db"
      "maybe-redis"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=web"
      "--network=maybe_maybe_net"
    ];
  };
  systemd.services."podman-maybe-web" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-maybe_maybe_net.service"
      "podman-volume-maybe_app-storage.service"
    ];
    requires = [
      "podman-network-maybe_maybe_net.service"
      "podman-volume-maybe_app-storage.service"
    ];
    partOf = [
      "podman-compose-maybe-root.target"
    ];
    wantedBy = [
      "podman-compose-maybe-root.target"
    ];
  };

  # === Web Worker
  virtualisation.oci-containers.containers."maybe-worker" = {
    image = "ghcr.io/maybe-finance/maybe:latest";
    environment = appEnv;
    environmentFiles = [ secretsFile ];
    cmd = [
      "bundle"
      "exec"
      "sidekiq"
    ];
    dependsOn = [
      "maybe-redis"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=worker"
      "--network=maybe_maybe_net"
    ];
  };
  systemd.services."podman-maybe-worker" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-maybe_maybe_net.service"
    ];
    requires = [
      "podman-network-maybe_maybe_net.service"
    ];
    partOf = [
      "podman-compose-maybe-root.target"
    ];
    wantedBy = [
      "podman-compose-maybe-root.target"
    ];
  };

  # == Networks
  systemd.services."podman-network-maybe_maybe_net" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "podman network rm -f maybe_maybe_net";
    };
    script = ''
      podman network inspect maybe_maybe_net || podman network create maybe_maybe_net --driver=bridge
    '';
    partOf = [ "podman-compose-maybe-root.target" ];
    wantedBy = [ "podman-compose-maybe-root.target" ];
  };

  # == Volumes
  systemd.services."podman-volume-maybe_app-storage" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman volume inspect maybe_app-storage || podman volume create maybe_app-storage
    '';
    partOf = [ "podman-compose-maybe-root.target" ];
    wantedBy = [ "podman-compose-maybe-root.target" ];
  };
  systemd.services."podman-volume-maybe_postgres-data" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman volume inspect maybe_postgres-data || podman volume create maybe_postgres-data
    '';
    partOf = [ "podman-compose-maybe-root.target" ];
    wantedBy = [ "podman-compose-maybe-root.target" ];
  };
  systemd.services."podman-volume-maybe_redis-data" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman volume inspect maybe_redis-data || podman volume create maybe_redis-data
    '';
    partOf = [ "podman-compose-maybe-root.target" ];
    wantedBy = [ "podman-compose-maybe-root.target" ];
  };

  # == Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."podman-compose-maybe-root" = {
    unitConfig = {
      Description = "Maybe Root Service";
    };
    wantedBy = [ "multi-user.target" ];
  };

  # == Reverse Proxy
  networking.firewall = {
    allowedTCPPorts = [ 80 ];
  };

  services.nginx = {
    enable = true;

    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;

    virtualHosts = {
      "maybe.worldline.local" = {
        locations."/" = {
          recommendedProxySettings = true;
          proxyWebsockets = true;
          proxyPass = "http://127.0.0.1:${PORT}";
        };
      };
    };
  };
}
