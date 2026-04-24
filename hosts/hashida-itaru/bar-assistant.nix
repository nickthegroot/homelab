{
  services.bar-assistant = {
    enable = true;
    appKeyFile = "/var/lib/secrets/bar-assistant-key";
    hostName = "http://bar-api.worldline.local";
    redis.enable = true;
    meilisearch.enable = true;
  };
}
