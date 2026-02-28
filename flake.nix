{
  description = "Telegram iOS build shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [ "aarch64-darwin" "x86_64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
    in
    {
      devShells = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              python3
              openssl
              bazelisk
              git
              curl
              unzip
              rsync
              gnumake
              coreutils
            ];

            shellHook = ''
              export USE_BAZEL_VERSION="8.3.1"
              echo "Note: Xcode is required and is not provided by Nix."
            '';
          };
        });
    };
}
