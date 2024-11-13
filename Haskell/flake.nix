{
  description = "Template Flake for Haskell Projects";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  };

  outputs = { self, nixpkgs }:
    let
      packageName = "TAPL";
      system = "x86_64-linux";
      compiler = "ghc9101";
      overlays = {
        haskell = final: prev: {
          myPackage = final.callCabal2nix packageName ./. {};
        };
      };
      pkgs = nixpkgs.legacyPackages.${system};
      haskellPackages = pkgs.haskell.packages.${compiler}.extend overlays.haskell;
    in
    {
      packages.${system}.default = haskellPackages.myPackage;
    };
}
