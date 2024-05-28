{
  description = "fitness tracker";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    backend = {
      url = "github:JD95/fitness-tracker-web-backend?rev=a66ac3b2ad04c2e48a7861167fe447b15f29ee6e";
    };

    frontend = {
      url = "github:JD95/fitness-tracker-web-frontend?rev=e7d9daf085bb92e66ee06964860f226c21dfe34d";
    };
  };

  outputs = { self, nixpkgs, backend, frontend, ... }@inputs:
    let
      forSystem = system: f: f {
        outputPackages = self.outputs.packages.${system};
        nixpkgs = inputs.nixpkgs.legacyPackages.${system};
        backendDrv = backend.outputs.packages.${system}.default;
        frontendDrv = frontend.outputs.packages.${system}.default;
      };

      package = { nixpkgs, backendDrv, frontendDrv, ... }:
        nixpkgs.stdenv.mkDerivation {
          name = "fitness-tracker";

          buildInputs = [ backendDrv frontendDrv ];

          backend = backendDrv;
          frontend = frontendDrv;

          unpackPhase = ''
            printenv
            mkdir -p out
            mkdir -p out/bin/
            mkdir -p out/frontend
            cp -r $backend/bin/* out/bin
            cp -r $frontend/* out/frontend
            '';

          installPhase = ''
            mkdir -p $out
            cp -r out/* $out
          '';
      };

      docker = { outputPackages, nixpkgs, ... }:
        nixpkgs.dockerTools.buildImage {
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

        fromImageName = "alpine-glibc";

        copyToRoot = nixpkgs.buildEnv {
          name = "image-root";
          paths = [
            outputPackages.default
            nixpkgs.sqlite
            nixpkgs.gmp
          ];
          pathsToLink = [ "/bin" "/frontend" ];
        };

        config = {
          Cmd = [ "fitness-tracker" ];
        };
      };

    devShell = {nixpkgs, ...}: nixpkgs.mkShell {
        buildInputs = [
          nixpkgs.dhall
          nixpkgs.dhall-json
          nixpkgs.dhall-bash
        ];
    };

    pkgs = inputs.nixpkgs.legacyPackages."x86_64-linux";

    executeWithLog = name: program:
      let
        id = pkgs.lib.escapeShellArg "hydra-${name}";
      in pkgs.writeScript "run-with-log-${name}" ''
        #!${pkgs.runtimeShell}
        set -e
        echo "Executing " ${pkgs.lib.escapeShellArg program} ", logs will appear in the systemd journal. View those logs with:" >&2
        echo "journalctl --identifier ${id}" >&2
        echo "Starting ${pkgs.lib.escapeShellArg program}..." | ${pkgs.systemd}/bin/systemd-cat --identifier ${id}
        ${pkgs.systemd}/bin/systemd-cat --identifier ${id} ${pkgs.lib.escapeShellArg program}
      '';

    pushDockerImageScript = pkgs.writeScript "push-image.sh" ''
      #!${pkgs.runtimeShell}

      IMAGE_PATH="${self.packages."x86_64-linux".docker}"
      DEST="docker.io/jdwyer95/fitness-server:latest"
      SECRETS="$(${pkgs.sops}/bin/sops --decrypt /var/lib/hydra/queue-runner/secrets/passwords.yaml)"
      PASS="$(echo "$SECRETS" | ${pkgs.yq}/bin/yq ".passwords.dockerhub")"

      echo "logging into docker..."
      ${pkgs.skopeo}/bin/skopeo login docker.io --username jdwyer95 --password $(eval echo $PASS)
      echo "copying images..."
      ${pkgs.skopeo}/bin/skopeo copy docker-archive://$IMAGE_PATH docker://$DEST
      echo "done"
    '';
    pushImage = executeWithLog "fitness-tracker-push-image" pushDockerImageScript;

    in {
      packages."x86_64-linux".default = forSystem "x86_64-linux" package;
      packages."x86_64-linux".docker = forSystem "x86_64-linux" docker;
      devShells."x86_64-linux".default = forSystem "x86_64-linux" devShell;
      inherit pushImage;
      hydraJobs = {
        inherit (self) packages;
        runCommandHook = { inherit pushImage; };
      };
    };
}
