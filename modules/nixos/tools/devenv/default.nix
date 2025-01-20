{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.nos.tools.devenv;
in
{
  options.nos.tools.devenv = {
    enable = mkEnableOption "Enable devenv.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.devenv ];
  };
}
