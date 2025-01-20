{
  lib,
  config,
  inputs,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    forEach
    length
    concatStringsSep
    concatMap
    optionals
    optionalAttrs
    ;
  inherit (lib.nos) enabled disabled recursiveMergeAttrs;
  cfg = config.nos.desktop.hyprland;

  workspace-sh = pkgs.writeShellApplication {
    name = "workspace";
    runtimeInputs = [ pkgs.jq ];
    text = builtins.readFile ./scripts/workspace.sh;
  };

  screenshot-sh = pkgs.writeShellApplication {
    name = "screenshot";
    runtimeInputs = [ pkgs.grimblast ];
    text = builtins.readFile ./scripts/screenshot.sh;
  };
in
{
  options.nos.desktop.hyprland = {
    enable = mkEnableOption "Enable hyprland with addons.";
    monitors = mkOption {
      default = [ ];
      description = "A list of monitors settings";
      type = types.listOf (
        types.submodule {
          options = {
            disabled = mkOption {
              type = types.bool;
              description = "Is the display disabled?";
              default = false;
            };
            height = mkOption {
              type = types.int;
              description = "The pixel width of the display.";
            };
            name = mkOption {
              type = types.str;
              description = "The name of the display.";
            };
            position = mkOption {
              type = types.str;
              default = "0x0";
              description = "The position of the display.";
            };
            refreshRate = mkOption {
              type = types.int;
              default = 60;
              description = "The refresh rate of the display.";
            };
            vrr = mkOption {
              type = types.bool;
              description = "Is the display enabled?";
              default = false;
            };
            scale = mkOption {
              type = lib.types.str;
              default = "1";
              description = "The scale of the display.";
            };
            vertical = mkOption {
              type = types.bool;
              description = "Is the display vertical?";
              default = false;
            };
            width = mkOption {
              type = types.int;
              description = "The pixel width of the display.";
            };
            workspaces = mkOption {
              type = types.listOf types.int;
              description = "The list of workspace numbers.";
            };
          };
        }
      );
    };
    extraSettings = mkOption {
      default = { };
      description = "Extra settings to pass to hyprland.";
      type = types.attrs;
    };
  };

  config = mkIf cfg.enable {
    services.xserver = enabled;
    programs.hyprland = enabled // {
      withUWSM = true;
    };

    nos.cli-apps.matugen.templates."hyprland-colors" = {
      outputPath = "/home/${config.nos.user.name}/.config/hypr/colors.conf";
      text = ''
        $image = {{image}}
        <* for name, value in colors *>
        ''${{name}} = rgba({{value.default.hex_stripped}}ff)
        <* endfor *>
      '';
    };

    nos.home.extraOptions.wayland.windowManager.hyprland = enabled // {
      systemd = disabled;
      xwayland = enabled;
      settings = recursiveMergeAttrs [
        (import ./settings.nix {
          inherit
            lib
            config
            pkgs
            inputs
            workspace-sh
            screenshot-sh
            ;
        })
        {
          monitor = forEach cfg.monitors (
            monitor:
            if !monitor.disabled then
              concatStringsSep "," (
                [
                  monitor.name
                  "${toString monitor.width}x${toString monitor.height}@${toString monitor.refreshRate}"
                  monitor.position
                  monitor.scale
                ]
                ++ optionals monitor.vrr [ "vrr,1" ]
                ++ optionals monitor.vertical [ "transform,1" ]
              )
            else
              concatStringsSep "," [
                monitor.name
                "disabled"
              ]
          );
        }
        (optionalAttrs (length cfg.monitors > 1) {
          workspace = concatMap (
            monitor: map (ws: "${toString ws},monitor:${monitor.name}") monitor.workspaces
          ) (builtins.filter (m: !m.disabled) cfg.monitors);
        })
        cfg.extraSettings
      ];
    };

    environment.systemPackages = [
      workspace-sh
      screenshot-sh
      # pkgs.wl-clipboard
      # pkgs.xclip
    ];

    environment = {
      variables = {
        XDG_CURRENT_DESKTOP = "Hyprland";
        XDG_SESSION_TYPE = "wayland";
        XDG_SESSION_DESKTOP = "Hyprland";
      };
      sessionVariables = {
        NIXOS_OZONE_WL = "1";
        T_QPA_PLATFORM = "wayland";
      };
    };

    xdg.portal = enabled // {
      xdgOpenUsePortal = true;
      config = {
        common.default = [ "gtk" ];
        hyprland.default = [
          "gtk"
          "hyprland"
        ];
      };
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };
  };
}
