{ nixos-hardware, ... }:
{
  imports = [
    nixos-hardware.nixosModules.dell-xps-13-9350
  ];

  # Disable screen after 5m
  boot.kernelParams = [
    "consoleblank=300"
  ];

  # Ignore lid
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
  };
}
