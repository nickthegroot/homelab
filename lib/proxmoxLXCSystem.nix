{
  inputs,
  system,
  mylib,
  myvars,
  # Per-host
  sshLoginKey,
  nixos-modules,
  ...
}:
let
  inherit (inputs) nixpkgs;
  specialArgs = inputs // {
    inherit mylib myvars;
  };
in
nixpkgs.lib.nixosSystem {
  inherit system specialArgs;
  modules = nixos-modules ++ [
    ../modules/proxmox
    {
      services.openssh.enable = true;
      users.users.root.openssh.authorizedKeys.keys = [ sshLoginKey ];
    }
  ];
}
