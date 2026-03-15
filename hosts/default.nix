inputs:
let
  inherit (inputs.nixpkgs) lib;
  mylib = import ../lib { inherit lib; };

  createSystem =
    wrapper: system: hostPath:
    let
      systemConfig = import hostPath { inherit mylib; };
    in
    {
      inherit (systemConfig) name;
      value = wrapper (
        systemConfig
        // {
          inherit
            inputs
            system
            mylib
            ;
        }
      );
    };

  createSystems =
    wrapper: hosts:
    lib.lists.flatten (
      lib.attrsets.mapAttrsToList (system: hostPaths: map (createSystem wrapper system) hostPaths) hosts
    );

  nixosHosts = {
    x86_64-linux = [ ./hashida-itaru ];
  };

  nixosSystems = createSystems mylib.nixosSystem nixosHosts;
in
{
  nixosConfigurations = builtins.listToAttrs nixosSystems;
}
