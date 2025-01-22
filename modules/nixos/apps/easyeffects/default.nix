{
  lib,
  config,
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

  cfg = config.nos.apps.easyeffects;
in
{
  options.nos.apps.easyeffects = {
    enable = mkEnableOption "Enable easyeffects.";
    preset = mkOption {
      default = "";
      description = "The default preset to load.";
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    nos.home.configFile."easyeffects/output/${cfg.preset}.json" = mkIf (cfg.preset != "") {
      text = builtins.readFile ./${cfg.preset}.json;
    };

    nos.home.extraOptions.services.easyeffects = enabled // {
      inherit (cfg) preset;
    };
  };
}
