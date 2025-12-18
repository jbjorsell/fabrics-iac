{
  pkgs,
  lib,
  config,
  ...
}:
{
  cachix.enable = false;

  # https://devenv.sh/packages/
  packages = [
    pkgs.azure-cli
    pkgs.just
    pkgs.opentofu
  ];

  # https://devenv.sh/languages/
  languages.python = {
    enable = true;
    uv.enable = true;
  };

  # See full reference at https://devenv.sh/reference/options/
}
