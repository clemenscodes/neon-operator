{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
    };
  };
  outputs = {
    self,
    nixpkgs,
    flake-parts,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {inherit system;};
  in
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [inputs.flake-parts.flakeModules.easyOverlay];
      systems = [system];
      perSystem = {
        config,
        system,
        ...
      }: {
        formatter = pkgs.alejandra;

        devShells = {
          default = pkgs.mkShellNoCC {
            buildInputs = with pkgs; [
              alejandra
              nil
              hadolint
              lazydocker
              lazygit
              kubectl
              kind
              tilt
              k9s
              gnumake
              docker
              go
            ];
            shellHook = ''
              echo "kubectl $(kubectl version --client)"
              echo "kind Version: $(kind version | awk '{print $2}')"
              echo "tilt Version: $(tilt version | awk -F ',' '{print $1}')"
              echo "k9s Version: $(k9s version -s | head -n1 | awk '{print $2}')"
              echo "lazydocker $(lazydocker --version | head -n1)"
              echo "make Version: $(make --version | head -n1 | awk '{print $3}')"
              echo "go Version: $(go version | awk '{print $3}' | sed 's/^go//')"
            '';
          };
        };
      };
    };
}
