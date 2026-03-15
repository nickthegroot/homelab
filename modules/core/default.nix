{
  pkgs,
  mylib,
  agenix,
  ...
}:
{
  imports = [
    agenix.nixosModules.default
    ../services/default.nix
  ];

  nixpkgs.overlays = [
    (
      final: prev:
      let
        newPackageFiles = mylib.scanPaths ../../packages;
        newPackageNames = map (
          path: prev.lib.strings.removeSuffix ".nix" (baseNameOf path)
        ) newPackageFiles;
      in
      prev.lib.genAttrs newPackageNames (
        name: prev.callPackage (../../packages + "/${name}/package.nix") { }
      )
    )
  ];

  time.timeZone = "America/Los_Angeles";

  nix.optimise.automatic = true;
  programs.nh = {
    enable = true;
    clean.enable = true;
  };

  environment.systemPackages = with pkgs; [
    neovim
    git
    git-lfs

    # archives
    zip
    unzip
    p7zip

    # Text Processing
    jq

    # networking tools
    wget
    curl

    # misc
    which
    tree
    gnutar
    rsync
    yazi
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.11"; # Did you read the comment?
}
