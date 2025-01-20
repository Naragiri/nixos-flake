{
  lib,
  config,
  ...
}:
let
  inherit (lib)
    mkOption
    mkForce
    types
    toLower
    ;
  inherit (lib.nos) attrsToLines;
  cfg = config.nos.system;
in

{
  options.nos.system = {
    osReleaseContent = mkOption {
      type = types.attrsOf types.str;
      default = {
        inherit (config.system.nixos) release codeName version;
        distroName = "Nara OS";
        distroId = "naraos";
      };
    };
  };

  config = {
    environment.etc."os-release" =
      let
        osReleaseContents = {
          NAME = "${cfg.osReleaseContent.distroName}";
          ID = "${cfg.osReleaseContent.distroId}";
          VERSION = "${cfg.osReleaseContent.release} (${cfg.osReleaseContent.codeName})";
          VERSION_CODENAME = toLower cfg.osReleaseContent.codeName;
          VERSION_ID = cfg.osReleaseContent.release;
          BUILD_ID = cfg.osReleaseContent.version;
          PRETTY_NAME = "${cfg.osReleaseContent.distroName} ${cfg.osReleaseContent.release} (${cfg.osReleaseContent.codeName})";
          LOGO = "nix-snowflake";
          HOME_URL = "https://github.com/Naragiri/nixos-flake";
        };
      in
      mkForce {
        text = attrsToLines osReleaseContents;
      };
  };
}
