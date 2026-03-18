{
  inputs,
  system,
  mylib,

  # Per-host
  name,
  nixos-modules,
  sshLoginKey,
  ...
}:
let
  inherit (inputs) nixpkgs;
  specialArgs = inputs // {
    inherit mylib;
  };

in
nixpkgs.lib.nixosSystem {
  inherit system specialArgs;
  modules = nixos-modules ++ [
    ../modules/core
    {
      services.openssh = {
        enable = true;
        settings = {
          KbdInteractiveAuthentication = false;
          PermitRootLogin = "no";
        };
      };

      users.users.nickthegroot = {
        isNormalUser = true;
        openssh.authorizedKeys.keys = [ sshLoginKey ];
        extraGroups = [
          "nickthegroot"
          "users"
          "networkmanager"
          "wheel"
        ];
      };
      users.groups.nickthegroot = { };

      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      networking = {
        hostName = name;
        networkmanager.enable = true;
      };
    }
  ];
}
