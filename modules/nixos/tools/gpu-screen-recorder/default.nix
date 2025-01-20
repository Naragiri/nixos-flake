{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  inherit (lib.nos) enabled;
  cfg = config.nos.tools.gpu-screen-recorder;
in
{
  options.nos.tools.gpu-screen-recorder = {
    enable = mkEnableOption "Enable gpu-screen-recorder.";
    ui.package = mkOption {
      default = pkgs.nos.gpu-screen-recorder-ui.override {
        inherit (config.security) wrapperDir;
      };
      description = "The gpu-screen-recorder-ui package.";
      type = types.package;
    };
  };

  config = mkIf cfg.enable {
    programs.gpu-screen-recorder = enabled;

    environment.systemPackages = [
      cfg.ui.package
    ];

    systemd.packages = [ cfg.ui.package ];

    security.wrappers."gsr-global-hotkeys" = {
      owner = "root";
      group = "root";
      capabilities = "cap_setuid+ep";
      source = "${cfg.ui.package}/bin/gsr-global-hotkeys";
    };
  };
}
