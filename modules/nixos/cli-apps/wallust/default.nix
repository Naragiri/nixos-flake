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
  cfg = config.nos.cli-apps.wallust;
in
{
  options.nos.cli-apps.wallust = {
    enable = mkEnableOption "Enable wallust.";
    addons = {
      pywal.enable = mkEnableOption "Add a legacy template for pywal colors.";
      shell.enable = mkEnableOption "Add shell init hook.";
      vencord.enable = mkEnableOption "Add a vencord template.";
    };
    templates = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            new_engine = mkOption {
              default = true;
              description = "Should this template use the new engine.";
              type = types.bool;
            };
            text = mkOption {
              default = "";
              description = "Content of the template file.";
              type = types.str;
            };
            target = mkOption {
              default = "";
              description = "Absolute path to the file to write the template after processing.";
              type = types.str;
            };
          };
        }
      );
      default = { };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.wallust ];

    nos.desktop.addons.waypaper.onWallpaperChange = [ "wallust run $1" ];

    nos = {
      cli-apps.wallust.templates = {
        "pywal-compat" = mkIf cfg.addons.pywal.enable {
          text = ''
            {{color0}}
            {{color1}}
            {{color2}}
            {{color3}}
            {{color4}}
            {{color5}}
            {{color6}}
            {{color7}}
            {{color8}}
            {{color9}}
            {{color10}}
            {{color11}}
            {{color12}}
            {{color13}}
            {{color14}}
            {{color15}}
          '';
          target = "/home/${config.nos.user.name}/.cache/wal/colors";
        };
      };

      home = {
        extraOptions.programs = mkIf cfg.addons.shell.enable {
          zsh.initExtra = mkIf (config.nos.system.shell.name == "zsh") ''
            sequences="/home/${config.nos.user.name}/.cache/wallust/sequences"
            if [ -e "$sequences" ]; then
              command cat "$sequences"
            fi
          '';
        };

        configFile =
          {
            "wallust/wallust.toml".source = (pkgs.formats.toml { }).generate "wallust-config-toml" {
              backend = "resized";
              check_contrast = true;
              color_space = "labmixed";
              fallback_generator = "interpolate";
              palette = "dark16";
              templates = lib.mapAttrs (filename: attr: {
                inherit (attr) target new_engine;
                template = filename;
              }) cfg.templates;
              threshold = 20;
            };
          }
          // (lib.mapAttrs' (
            template: { text, ... }: lib.nameValuePair "wallust/templates/${template}" { inherit text; }
          ) cfg.templates);
      };
    };
  };
}
