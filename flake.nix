{
  description = "A development environment for PowerShell module development";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        unstable = import nixpkgs {
          inherit system;
        };
      in
      {
        devShell = unstable.mkShell {
          buildInputs = [
            unstable.powershell
            unstable.protobuf_21
            unstable.protoc-gen-js
            unstable.protoc-gen-grpc-web
          ];

          shellHook = ''
            export SHELL="${unstable.powershell}/bin/pwsh"

            pwsh

            exit 0
          '';
        };
      }
    );
}