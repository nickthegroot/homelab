{ nixos-hardware, ... }:
{
  imports = [
    nixos-hardware.nixosModules.dell-xps-13-9350
  ];

  boot.kernelParams = [
    "consoleblank=300"
    "nomodeset"
  ];

  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchDocked = "ignore";
  };
  systemd.targets = {
    sleep.enable = false;
    suspend.enable = false;
    hibernate.enable = false;
    hybrid-sleep.enable = false;
  };
}
