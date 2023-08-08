{
  description = "fitness trakcer frontend";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    backend.url = "github:JD95/fitness-tracker-web-backend";
    frontend.url = "github:JD95/fitness-tracker-web-frontend";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, backend, frontend, ... }@inputs:
    let 
      package = system: drvAttrs {
        nixpkgs = inputs.nixpkgs.legacyPackages.${system};
        backendDrv = backend.outputs.packages.${system}.default;
        frontendDrv = frontend.outputs.packages.${system}.default;
      };

      drvAttrs = { nixpkgs, backendDrv, frontendDrv }:
        nixpkgs.stdenv.mkDerivation {
          name = "fitness-tracker";

          buildInputs = [ backendDrv frontendDrv ];
       
          backend = backendDrv; 
          frontend = frontendDrv; 

          unpackPhase = ''
            printenv
            mkdir -p out
            mkdir -p out/bin/
            mkdir -p out/bin/frontend
            cp -r $backend/bin/* out/bin
            cp -r $frontend/* out/bin/frontend 
            '';

          installPhase = ''
            mkdir -p $out
            cp -r out/* $out
          '';
      };

    in {
      packages."x86_64-linux".default = package "x86_64-linux";
      hydraJobs = { inherit (self) packages; };
    };
}
