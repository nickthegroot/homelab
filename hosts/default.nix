inputs:
let
  inherit (inputs.nixpkgs) lib;
  mylib = import ../lib { inherit lib; };
  myvars = import ../vars;

  createSystem =
    wrapper: system: hostPath:
    let
      systemConfig = import hostPath;
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
            myvars
            ;
        }
      );
    };

  createSystems =
    wrapper: hosts:
    lib.lists.flatten (
      lib.attrsets.mapAttrsToList (system: hostPaths: map (createSystem wrapper system) hostPaths) hosts
    );

  proxmoxLXCHosts = {
    x86_64-linux = [
      ./tennouji-yuugo
      ./tennouji-nae
    ];
  };

  proxmoxLXCSystems = createSystems mylib.proxmoxLXCSystem proxmoxLXCHosts;
in
{
  nixosConfigurations = builtins.listToAttrs proxmoxLXCSystems;
}
