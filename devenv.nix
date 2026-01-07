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
    (pkgs.azure-cli.withExtensions [ pkgs.azure-cli-extensions.microsoft-fabric ])
    pkgs.just
    pkgs-unstable.opentofu # Unstable needed for version 1.11 (2025-12-18)
    pkgs.terraform # Open tofu did not work fully, so we go with terraform for now
  ];

  # https://devenv.sh/languages/
  languages.python = {
    enable = true;
    uv.enable = true;
  };

  # See full reference at https://devenv.sh/reference/options/
}
