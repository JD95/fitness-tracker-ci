{
  description = "fitness trakcer frontend";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    backend.url = "github:JD95/fitness-tracker-web-backend";
    frontend.url = "github:JD95/fitness-tracker-web-frontend";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, backend, frontend, ... }@inputs:
    flake-utils.lib.eachSystem ["x86_64-linux"] (system:
    let 
      nixpkgs = inputs.nixpkgs.legacyPackages.${system};
    in {
      packages.default = nixpkgs.stdenv.mkDerivation {
        name = "fitness-tracker";

        # src = ./server/flake.nix ./frontend/flake.nix;
        buildInputs = [ 
          backend.packages.${system}.default
          frontend.packages.${system}.default
        ];
        unpackPhase = ''
          cp -r $backend .
          mkdir frontend
          cp -r $frontend frontend/
          '';
        installPhase = ''
          mkdir -p $out
          mv fitness-server $out/
          mv frontend $out/frontend
          '';
      };
  });
}
