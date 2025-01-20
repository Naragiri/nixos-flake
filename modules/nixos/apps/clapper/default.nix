{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.nos.apps.clapper;
in
{
  options.nos.apps.clapper = {
    enable = mkEnableOption "Enable clapper.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.clapper ];

    nos.home.extraOptions.xdg.mimeApps.defaultApplications = {
      "video/mp4" = "clapper.desktop";
      "video/mpeg" = "clapper.desktop";
    };
  };
}
