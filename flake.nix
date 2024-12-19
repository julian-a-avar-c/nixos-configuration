{
  description = "NixOS configuration with two or more channels";

 inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    disko.url = "github:nix-community/disko/latest";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { nixpkgs, nixpkgs-unstable, disko, ... }:
    let
        system = "x86_64-linux";
    in {
      nixosConfigurations."exilis-celebensis" = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          {
            nixpkgs.overlays = [
              (final: prev: {
                # unstable = nixpkgs-unstable.legacyPackages.${prev.system};
                # use this variant if unfree packages are needed:
                unstable = import nixpkgs-unstable {
                  inherit system;
                  config.allowUnfree = true;
                };
              })
            ];
          }
          disko.nixosModules.disko
          ./configuration.nix
        ];
      };
    };
}
