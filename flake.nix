{
  description = "fitness trakcer frontend";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    backend.url = "github:JD95/fitness-tracker-web-backend";
    frontend.url = "github:JD95/fitness-tracker-web-frontend";
  };

  outputs = { self, nixpkgs, backend, frontend, ... }@inputs:
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

      packages."x86_64-linux".docker = nixpkgs.dockerTools.buildImage {
        name = "fitness-server";

        tag = "latest";

        fromImage = nixpkgs.dockerTools.pullImage {
          imageName = "frolvlad/alpine-glibc";
          finalImageName = "frolvlad/alpine-glibc";
          finalImageTag = "latest";
          imageDigest = "sha256:bd63755f76ec0a8192402bd3873aff96202c21edc5c2504e4bb927430fcfd211";
          sha256 = "1vpzmfp2bv4fzsv3agdsbwswbf2mdzv2arxcqs9jirr6adckl7qb";
          os = "linux";
          arch = "x86_64";
        };

        copyToRoot = nixpkgs.buildEnv {
          name = "image-root";
          paths = [ backendDrv frontendDrv ];
          pathsToLink = [ "/bin" ];
        };

        extraCommands = ''
        apk add sqlite sqlite-dev gmp
        '';

        config = {
          Cmd = [ "fitness-tracker" ];
        };
      };

      hydraJobs = { inherit (self) packages docker; };
    };
}
