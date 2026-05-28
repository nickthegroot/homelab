{
  description = "Homelab configurations for various systems";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    mokuro-bunko = {
      url = "github:nickthegroot/mokuro-bunko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: (import ./hosts inputs) // (import ./packages inputs);
}
