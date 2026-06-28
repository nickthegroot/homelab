{ config, ... }:

let
  meilisearchDomain = "meilisearch.home.nickthegroot.com";
  meilisearchUrl = "https://${meilisearchDomain}";
in
{
  services = {
    meilisearch = {
      enable = true;
      masterKeyFile = "/var/lib/secrets/meilisearch-key";
    };

    bar-assistant = rec {
      enable = true;
      appKeyFile = "/var/lib/secrets/bar-assistant-key";
      hostName = "https://bar-api.home.nickthegroot.com";
      appURL = hostName;

      redis.enable = true;
      meilisearch = {
        host = meilisearchUrl;
        keyFile = "/var/lib/secrets/meilisearch-key";
      };
    };

    salt-rim = {
      enable = true;
      hostName = "https://bar.home.nickthegroot.com";
      settings = {
        API_URL = "https://bar-api.home.nickthegroot.com";
        MEILISEARCH_URL = meilisearchUrl;
      };
    };

    caddy.virtualHosts."${meilisearchDomain}".extraConfig =
      "reverse_proxy localhost:${toString config.services.meilisearch.listenPort}";
  };
}
