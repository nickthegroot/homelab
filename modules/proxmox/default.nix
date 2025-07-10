{ modulesPath, ... }:
{
  # https://nixos.wiki/wiki/Proxmox_Virtual_Environment#LXC
  # https://nixos.wiki/wiki/Proxmox_Linux_Container
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/virtualisation/proxmox-lxc.nix

  imports = [
    ../core
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
  ];
  services.cloud-init.network.enable = true;

  proxmoxLXC = {
    enable = true;
    manageNetwork = false;
    privileged = false;
  };
}
