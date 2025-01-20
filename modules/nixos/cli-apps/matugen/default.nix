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
    optionalAttrs
    getExe
    ;
  cfg = config.nos.cli-apps.matugen;
in
{
  options.nos.cli-apps.matugen = {
    enable = mkEnableOption "Enable matugen.";
    templates = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            outputPath = mkOption {
              default = "";
              description = "Absolute path to the file to write the template after processing.";
              type = types.str;
            };
            postHook = mkOption {
              default = null;
              description = "Command to run after the image is processed.";
              type = types.nullOr types.str;
            };
            text = mkOption {
              default = "";
              description = "Content of the template file.";
              type = types.str;
            };
          };
        }
      );
      default = { };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.matugen ];

    nos.desktop.addons.waypaper.onWallpaperChange = [ "${getExe pkgs.matugen} image $1" ];

    nos.home.configFile =
      {
        "matugen/config.toml".source = (pkgs.formats.toml { }).generate "matugen-config-toml" {
          # config.wallpaper.set = true;
          config = { };
          templates = lib.mapAttrs (
            filename: attr:
            {
              output_path = attr.outputPath;
              input_path = "/home/${config.nos.user.name}/.config/matugen/templates/${filename}";
            }
            // optionalAttrs (attr.postHook != null) {
              post_hook = attr.postHook;
            }
          ) cfg.templates;
        };
      }
      // (lib.mapAttrs' (
        template: { text, ... }: lib.nameValuePair "matugen/templates/${template}" { inherit text; }
      ) cfg.templates);
  };
}
