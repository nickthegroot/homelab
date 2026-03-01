inputs:
let
  inherit (inputs.nixpkgs) lib;
  mylib = import ../lib { inherit lib; };

  packagesForSystem =
    system:
    let
      pkgs = import inputs.nixpkgs { inherit system; };
      packageFiles = mylib.scanPaths ./.;

      packageNames = map baseNameOf packageFiles;
    in
    lib.genAttrs packageNames (name: pkgs.callPackage (./. + "/${name}/package.nix") { });
in
{
  packages = lib.genAttrs lib.systems.flakeExposed packagesForSystem;
}
