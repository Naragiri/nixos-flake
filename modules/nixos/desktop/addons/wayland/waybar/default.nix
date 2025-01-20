{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
let
  inherit (lib)
    types
    mkEnableOption
    mkIf
    mkOption
    getExe
    ;
  inherit (lib.nos) recursiveMergeAttrs;
  cfg = config.nos.desktop.addons.waybar;
in
{
  options.nos.desktop.addons.waybar = {
    enable = mkEnableOption "Enable waybar.";
    extraSettings = mkOption {
      default = { };
      description = "Extra settings to pass to waybar.";
      type = types.attrs;
    };
    package = mkOption {
      default = pkgs.waybar;
      description = "The package for waybar.";
      type = types.package;
    };
  };

  config = mkIf cfg.enable {
    nos.cli-apps.matugen.templates."waybar-colors" = {
      outputPath = "/home/${config.nos.user.name}/.config/waybar/colors.css";
      postHook = "pkill waybar; uwsm app -- waybar &";
      text = ''
        <* for name, value in colors *>
          @define-color {{name}} {{value.default.hex}};
        <* endfor *>
      '';
    };

    nos.home.extraOptions.programs.waybar = {
      inherit (cfg) enable package;
      settings = recursiveMergeAttrs [
        {
          mainBar = {
            position = "top";
            layer = "top";

            margin-top = 6;
            margin-bottom = 0;
            margin-left = 8;
            margin-right = 8;
            spacing = 4;

            modules-left = [
              "custom/launcher"
              "hyprland/workspaces"
            ];
            modules-right = [
              "pulseaudio"
              "cpu"
              "network"
              "backlight"
              "custom/notifications"
              # "power-profiles-daemon"
              "battery"
              "clock"
              "tray"
            ];

            "custom/launcher" = {
              format = " ";
              on-click = "pkill rofi || ${getExe config.nos.desktop.addons.rofi.script} -show drun";
              tooltip = "false";
            };

            "hyprland/workspaces" = {
              # TODO: Use config.nos.desktop.hyprland.montitors
              persistent-workspaces = {
                DP-1 = [
                  1
                  2
                  3
                  4
                  5
                  6
                  7
                  8
                  9
                ];
                DP-2 = [
                  10
                  11
                  12
                  13
                  14
                  15
                  16
                  17
                  18
                ];
                eDP-1 = [
                  1
                  2
                  3
                  4
                  5
                  6
                  7
                  8
                  9
                ];
              };
            };

            pulseaudio = {
              scroll-step = 5;
              format = "{icon}  {volume}%";
              format-muted = "  {volume}%";
              "format-icons" = {
                "default" = [
                  " "
                  " "
                  " "
                ];
              };
              on-click-right = "pavucontrol";
            };

            cpu = {
              format = "  {usage}%";
              format-alt = "  {avg_frequency} GHz";
              interval = 1;
            };

            network = {
              format-wifi = "  ({signalStrength}%)";
              format-ethernet = "  Ethernet";
              format-disconnected = "⚠ Disconnected";
              format-alt = "{ifname}: {ipaddr}/{cidr}";
              on-click-right = "nm-connection-editor";
            };

            backlight = {
              format = "{icon} {percent}%";
              format-icons = [
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
              ];
              on-scroll-down = "${lib.getExe pkgs.brightnessctl} s 1%-";
              on-scroll-up = "${lib.getExe pkgs.brightnessctl} s +1%";
            };

            "custom/notifications" = {
              tooltip = false;
              format = "{icon}  {}";
              format-icons = {
                none = "";
                notification = "󱅫";
                dnd-notification = " ";
                dnd-none = "󰂛";
                inhibited-notification = " ";
                inhibited-none = "";
                dnd-inhibited-notification = " ";
                dnd-inhibited-none = " ";
              };
              return-type = "json";
              exec-if = "which swaync-client";
              exec = "swaync-client -swb";
              on-click = "swaync-client -d -sw";
              on-click-right = "swaync-client -t -sw";
              escape = true;
            };

            battery = {
              states = {
                good = 70;
                warning = 30;
                critical = 15;
              };
              format = "{icon}  {capacity}%";
              format-alt = "{time} {icon}";
              format-icons = [
                ""
                ""
                ""
                ""
                ""
              ];
              format-charging = "  {capacity}%";
            };

            clock = {
              calendar.format.today = "<span color='#b4befe'><b>{}</b></span>";
              timezone = "America/New_York";
              format = "  {:%I:%M}";
              format-alt = "  {:%m/%d/%Y}";
            };

            tray = {
              icon-size = 20;
            };
          };
        }
        cfg.extraSettings
      ];
      # https://github.com/0fie/Maika/tree/d93a048fe8f69b9bdebd44c81748bbfff3223a03
      # https://github.com/mylinuxforwork/dotfiles?tab=readme-ov-file
      # https://github.com/dxcently/dxflake/tree/main?tab=readme-ov-file
      style =
        let
          inherit (inputs.nix-colors.colorschemes.${colorscheme}) palette;

          font = "CaskaydiaCode NF";
          font_size = "16px";
          font_weight = "bold";

          # TODO: Make colorscheme global.
          colorscheme = "catppuccin-mocha";

          background = if config.nos.cli-apps.matugen.enable then "@primary" else "#${palette.base00}";
          text_color = if config.nos.cli-apps.matugen.enable then "@on_primary" else "#${palette.base06}";
          secondary_text_color =
            if config.nos.cli-apps.matugen.enable then "@inverse_primary" else "#${palette.base04}";
          active_text_color =
            if config.nos.cli-apps.matugen.enable then "@primary_container" else "#${palette.base0D}";

        in
        ''
          ${if config.nos.cli-apps.matugen.enable then "@import \"colors.css\";" else ""}

          * {
            border: none;
            border-radius: 0px;
            min-height: 0px;
            font-family: ${font};
            font-size: ${font_size};
            font-weight: ${font_weight};
          }

          window#waybar {
            background: transparent;
          }

          #workspaces {
            margin: 1px 1px 1px 1px;
            padding: 5px 6px 4px 6px;
            background: ${background};
            border-radius: 15px;
            font-style: normal;
          }

          #workspaces button {
            border-radius: 10px;
            color: ${text_color};
            padding: 2px 4px;
            margin: 3px 3px;
            min-width: 20px;
          }

          #workspaces button.empty {
            color: ${secondary_text_color};
          }

          #workspaces button.active,
          #workspaces button.active:hover,
          #workspaces button:hover {
            background: ${active_text_color};
            color: ${background};
          }

          #workspaces button.active, 
          #workspaces button.active:hover {
            min-width: 40px;
          }

          #pulseaudio, 
          #cpu, 
          #network, 
          #clock, 
          #tray, 
          #backlight, 
          #power-profiles-daemon, 
          #battery,
          #custom-notifications,
          #custom-launcher {
            background: ${background};
            color: ${text_color};
            border-radius: 15px;
            margin: 1px 4px 1px 4px;
            padding: 7px 10px 6px 10px;
          }

          #custom-launcher {
            padding: 0px 4px 0px 8px;
            font-size: 24px;
          }

          #pulseaudio {
            min-width: 75px;
          }

          #pulseaudio.muted {
            background: #${palette.base08};
            color: ${background};
          }

          #cpu {
            min-width: 55px;
          }

          #battery.low {
            background: #${palette.base08};
            color: ${background};
          }

          #battery.critical:not(.charging) {
            background: #${palette.base08};
            color: ${background};
            animation-name: blink;
            animation-duration: 0.5s;
            animation-timing-function: linear;
            animation-iteration-count: infinite;
            animation-direction: alternate;
          }

          #battery.charging {
            background: #${palette.base0A};
            color: ${background};
          }

          #network.disconnected {
            background: #${palette.base08};
            color: ${background};
          }

          /* If workspaces is the leftmost module, omit left margin */
          .modules-left > widget:first-child > #workspaces {
              margin-left: 0;
          }

          /* If workspaces is the rightmost module, omit right margin */
          .modules-right > widget:last-child > #workspaces {
              margin-right: 0;
          }

          #tray {
            -gtk-icon-shadow: 0 0 2px ${text_color};
          }
        '';
      # ''
      #   ${if config.nos.cli-apps.matugen.enable then "@import \"colors.css\";" else ""}

      #   * {
      #     border: none;
      #     border-radius: 0px;
      #     font-family: ${font};
      #     font-size: ${font_size};
      #     font-weight: ${font_weight};
      #     opacity: ${opacity};
      #   }

      #   window#waybar {
      #     background: transparent;
      #   }

      #   #workspaces {
      #     margin: 1px 1px 1px 1px;
      #     padding: 4px 6px;
      #     background: ${background};
      #     border-radius: 15px;
      #     border: 0px;
      #     font-style: normal;
      #   }

      #   #workspaces button {
      #     border-radius: 10px;
      #     color: ${text_color};
      #     padding: 2px 4px;
      #     margin: 3px 3px;
      #     min-width: 20px;
      #   }

      #   #workspaces button.empty {
      #     color: ${secondary_text_color};
      #   }

      #   #workspaces button.active,
      #   #workspaces button.active:hover,
      #   #workspaces button:hover {
      #     background: ${active_text_color};
      #     color: ${background};
      #   }

      #   #workspaces button.active,
      #   #workspaces button.active:hover {
      #     min-width: 40px;
      #   }

      #   #pulseaudio,
      #   #cpu,
      #   #network,
      #   #clock,
      #   #tray,
      #   #backlight,
      #   #power-profiles-daemon,
      #   #battery,
      #   #custom-notifications {
      #     background: ${background};
      #     color: ${text_color};
      #     border-radius: 15px;
      #     margin: 1px 4px 1px 4px;
      #     padding: 6px 10px;
      #   }

      #   #custom-launcher {
      #     background: ${background};
      #     color: ${text_color};
      #     border-radius: 15px;
      #     margin: 1px 4px 1px 4px;
      #     padding: 6px 10px;
      #     font-size: 24px;
      #   }

      #   #pulseaudio {
      #     min-width: 75px;
      #   }

      #   #pulseaudio.muted {
      #     background: #${palette.base08};
      #     color: ${background};
      #   }

      #   #cpu {
      #     min-width: 55px;
      #   }

      #   #battery.low {
      #     background: #${palette.base08};
      #     color: ${background};
      #   }

      #   #battery.critical:not(.charging) {
      #     background: #${palette.base08};
      #     color: ${background};
      #     animation-name: blink;
      #     animation-duration: 0.5s;
      #     animation-timing-function: linear;
      #     animation-iteration-count: infinite;
      #     animation-direction: alternate;
      #   }

      #   #battery.charging {
      #     background: #${palette.base0A};
      #     color: ${background};
      #   }

      #   #network.disconnected {
      #     background: #${palette.base08};
      #     color: ${background};
      #   }

      #   /* If workspaces is the leftmost module, omit left margin */
      #   .modules-left > widget:first-child > #workspaces {
      #       margin-left: 0;
      #   }

      #   /* If workspaces is the rightmost module, omit right margin */
      #   .modules-right > widget:last-child > #workspaces {
      #       margin-right: 0;
      #   }
      # '';
    };
  };
}
