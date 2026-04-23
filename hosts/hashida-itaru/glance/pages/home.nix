{ lib, config, ... }:
{
  name = "Home";
  columns = [
    {
      size = "small";
      widgets = [
        {
          type = "clock";
          hour-format = "12h";
          timezones = [
            {
              timezone = "America/Los_Angeles";
              label = "West Coast";
            }
            {
              timezone = "America/New_York";
              label = "East Coast";
            }
            {
              timezone = "Europe/London";
              label = "London";
            }
            {
              timezone = "Asia/Tokyo";
              label = "Tokyo";
            }
          ];
        }

        {
          type = "weather";
          units = "metric";
          location._secret = "/var/lib/secrets/location";
        }

        {
          type = "bookmarks";
          groups = [
            {
              links = lib.mapAttrsToList (
                url: v:
                let
                  # Extract the service name from the URL, e.g., "http://my-service.worldline.local"
                  service = builtins.match "http://([a-zA-Z0-9-]+)\\.worldline\\.local" url;
                  # Convert kebab-case to Title Case
                  title =
                    if service == null then
                      "Unknown"
                    else
                      builtins.concatStringsSep " " (
                        map (
                          word:
                          lib.strings.toUpper (builtins.substring 0 1 word)
                          + lib.strings.toLower (builtins.substring 1 (builtins.stringLength word) word)
                        ) (lib.strings.splitString "-" (builtins.elemAt service 0))
                      );
                in
                {
                  inherit title url;
                }
              ) config.services.caddy.virtualHosts;
            }
          ];
        }
      ];
    }

    # Content
    {
      size = "full";
      widgets = [
        {
          title = "xkcd";
          type = "rss";
          cache = "6h";
          feeds = [
            {
              url = "https://xkcd.com/rss.xml";
              title = "xkcd";
            }
          ];
          style = "horizontal-cards-2";
        }

        {
          title = "Favorites";
          type = "rss";
          limit = 10;
          collapse-after = 5;
          style = "detailed-list";
          feeds = [
            {
              url = "http://rss.worldline.local/api/query.php?user=admin&t=7hp4NHm5HNAmQjGPgq3m07&f=rss";
              title = "Favorites";
            }
          ];
        }

        {
          type = "hacker-news";
        }
      ];
    }

    # Stats
    {
      size = "small";
      widgets = [

        {
          type = "server-stats";
          servers = [
            {
              type = "local";
              name = "hashida-itaru";
              mountpoints = {
                "/mnt/media".name = "NAS";
              };
            }
          ];
        }

        (import ../plugins/unifi.nix)

        {
          type = "dns-stats";
          service = "technitium";
          url = "http://dns.worldline.local";
          token._secret = "/var/lib/secrets/technitium-api-token";
        }

        {
          type = "markets";
          markets = [
            {
              symbol = "VT";
              name = "Vanguard Total World";
            }
            {
              symbol = "VTI";
              name = "Vanguard Total US";
            }
          ];
        }

        (import ../plugins/mortgage.nix {
          title = "15-Year Fixed Rate Mortgage Avg";
          seriesId = "MORTGAGE15US";
        })

        (import ../plugins/mortgage.nix {
          title = "30-Year Fixed Rate Mortgage Avg";
          seriesId = "MORTGAGE30US";
        })
      ];
    }
  ];
}
