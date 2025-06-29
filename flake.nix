{
  description = "Homelab configurations for various systems";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ./hosts inputs;
}
