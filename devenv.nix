{
  pkgs,
  inputs,
  ...
}:
let
  pkgs-unstable = import inputs.nixpkgs-unstable { system = pkgs.stdenv.system; };
in
{
  cachix.enable = false;

  # https://devenv.sh/packages/
  packages = [
    pkgs.azure-cli
    pkgs.just
    pkgs-unstable.opentofu # Unstable needed for version 1.11 (2025-12-18)
  ];

  # https://devenv.sh/languages/
  languages.python = {
    enable = true;
    uv.enable = true;
  };

  # See full reference at https://devenv.sh/reference/options/
}
