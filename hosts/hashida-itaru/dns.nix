{
  services = {
    technitium-dns-server = {
      enable = true;
      openFirewall = true;
    };

    # https://technitium.com/dns/
    caddy.virtualHosts."http://dns.worldline.local".extraConfig = "reverse_proxy localhost:5380";
  };
}
