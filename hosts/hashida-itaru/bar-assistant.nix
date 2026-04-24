{ config, ... }:

let
  meilisearchUrl = "http://meilisearch.worldline.local";
in
{
  services = {
    meilisearch = {
      enable = true;
      masterKeyFile = "/var/lib/secrets/meilisearch-key";
    };

    bar-assistant = {
      enable = true;
      appKeyFile = "/var/lib/secrets/bar-assistant-key";
      hostName = "http://bar-api.worldline.local";

      redis.enable = true;
      meilisearch = {
        host = meilisearchUrl;
        keyFile = "/var/lib/secrets/meilisearch-key";
      };
    };

    salt-rim = {
      enable = true;
      hostName = "http://bar.worldline.local";
      settings = {
        API_URL = "http://bar-api.worldline.local";
        MEILISEARCH_URL = meilisearchUrl;
      };
    };

    caddy.virtualHosts."${meilisearchUrl}".extraConfig =
      "reverse_proxy localhost:${toString config.services.meilisearch.listenPort}";
  };
}
