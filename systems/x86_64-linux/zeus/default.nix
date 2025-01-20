{
  pkgs,
  inputs,
  lib,
  ...
}:
let
  inherit (lib) getExe;
  inherit (lib.nos) enabled;
  inherit (inputs) nixos-hardware;
in
{
  imports = [
    ./hardware-configuration.nix
    ./disk-configuration.nix
    nixos-hardware.nixosModules.framework-16-7040-amd
    nixos-hardware.nixosModules.common-gpu-amd
  ];

  nos = {
    apps = {
      chatterino = enabled;
      chromium = enabled // {
        makeDefaultBrowser = true;
      };
      discord = enabled;
      easyeffects = enabled // {
        preset = "ee_bryan_preset"; # https://community.frame.work/t/framework-16-sound-quality/46635
      };
      firefox = enabled;
      launchers = {
        lutris = enabled;
        xivlauncher = enabled;
      };
      minecraft = enabled;
      nemo = enabled;
      pqiv = enabled;
      qbittorrent = enabled;
      spotify = enabled;
      steam = enabled // {
        protonup = enabled;
      };
      terminal.kitty = enabled;
      vscode = enabled // {
        customCSS = ''
                    /* Tabs */
          .tabs-container {
              font-family: 'JetBrains Mono', Consolas, 'Courier New', monospace !important;
          }

          .monaco-workbench .part.editor>.content .editor-group-container>.title .tabs-container>.tab .tab-label a, .monaco-workbench .part.editor>.content .editor-group-container>.title .title-label a {
              font-size: 11px;
          }

          .line-numbers {
              position: relative !important;
              width: 25px !important;
              font-size: 14px !important;
              font-family: 'JetBrains Mono', Consolas, 'Courier New', monospace !important;
          }

          /* File Explorer Item Label */
          .monaco-tree .monaco-tree-row .label-name,
          .monaco-list .monaco-list-row
          .monaco-icon-label .label-name {
              font-family: 'JetBrains Mono', Consolas, 'Courier New', monospace !important;
              font-size: 12px !important;
              font-weight: 400 !important;
          }

          /* Scroll Bar */
          .slider {
              position: absolute !important;
              right: 5px !important;
              width: 5px !important;
              left: auto !important;
          }

          /* Search Label */
          .search-label {
              font-family: 'JetBrains Mono', Consolas, 'Courier New', monospace !important;
          }

          /* Command Palette */
          .quick-input-widget {
              transform: translateY(-50%) !important;
              top: 50% !important;
              box-shadow: 0px 8px 20px rgba(0, 0, 0, .45) !important;
              padding: 10px 10px 18px 10px !important;
              background-color: rgba(0, 0, 0, 0.8) !important;
              border-radius: 20px !important;
          }

          /* Command palette text input */
          .quick-input-filter .monaco-inputbox {
              border-radius: 12px !important;
              padding: 8px !important;
              border: none !important;
              background-color: rgba(34, 34, 34, .1) !important;
              font-family: 'JetBrains Mono', Consolas, 'Courier New', monospace !important;
              font-size: 14px !important;
              margin-bottom: 16px !important;
          }

          /* Command palette's input box placeholder. */
          .monaco-inputbox input::placeholder {
              color: rgba(233, 233, 233, 0.6) !important;
          }
        '';
      };
      # waydroid = enabled // { weston-wrapper = enabled; };
      # zen-browser = enabled;
    };
    cli-apps = {
      ani-cli = enabled;
      fastfetch = enabled;
      lf = enabled;
      ncmpcpp = enabled;
      # neovim = enabled;
      yazi = enabled;
    };
    desktop = {
      addons = {
        gammastep = enabled;
        gnome-keyring = enabled;
        gtk = enabled // {
          cursorTheme = {
            name = "Simp1e-Adw-Dark";
            package = pkgs.simp1e-cursors;
            size = 24;
          };
          iconTheme = {
            name = "Tela-manjaro";
            package = pkgs.tela-icon-theme;
            # name = "Papirus-Dark";
            # package = pkgs.papirus-icon-theme.override { color = "white"; };
          };
          theme = {
            # name = "catppuccin-mocha-teal-compact";
            # package = pkgs.catppuccin-gtk.override {
            #   accents = [ "teal" ];
            #   variant = "mocha";
            #   size = "compact";
            # };
            name = "Skeuos-Cyan-Dark";
            package = pkgs.nos.skeuos-gtk-theme.override {
              variant = "Dark";
              colorVariant = "Cyan";
            };
          };
        };
        polkit-gnome = enabled;
        rofi = enabled // {
          addons = {
            beats = enabled;
            calc = enabled;
            emoji = enabled;
          };
          rofi-themes = enabled // {
            launcher = enabled // {
              type = 2;
              style = 2;
            };
            colorscheme = "catppuccin-mocha";
          };
          wayland = enabled;
        };
        greetd = enabled;
        swaync = enabled;
        wallpapers = enabled // {
          # prism = enabled;
        };
        waybar = enabled;
        waypaper = enabled // {
          extraSettings.swww_transition_fps = 144;
        };
      };
      hyprland = enabled // {
        monitors = [
          {
            name = "eDP-1";
            width = 2560;
            height = 1600;
            refreshRate = 165;
            position = "2560x0";
            scale = "1.25";
            workspaces = [
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
          }
        ];
        extraSettings = {
          input.touchpad = {
            disable_while_typing = true;
            natural_scroll = false;
            tap-to-click = true;
          };
          gestures = {
            workspace_swipe = true;
          };
          windowrulev2 = [
            "workspace 2 silent,tag:browser"
            "workspace 3 silent,tag:discord"
            "workspace 4 silent,tag:music"
            "workspace 5 silent,class:(steam)"
            "workspace 6, tag:games"
          ];
          workspace = [
            "special:scratchpad, on-created-empty:kitty"
          ];
        };
      };
    };
    hardware = {
      audio = enabled;
      bluetooth = enabled;
      network = enabled;
      ssd = enabled;
    };
    services = {
      flatpak = enabled;
      mpd = enabled;
      openssh = enabled;
      syncthing = enabled;
    };
    system = {
      battery = enabled;
      boot = {
        plymouth = enabled;
        lanzaboote = enabled;
      };
      security = {
        doas = enabled;
      };
    };
    tools = {
      common = enabled;
      direnv = enabled;
      disko = enabled;
      nix-ld = enabled;
      git = enabled;
      qmk = enabled;
      zoxide = enabled;
    };
  };

  services.xserver.displayManager.setupCommands = with pkgs; ''
    ${getExe xorg.xrandr} --output eDP-1 --scale 0.8x0.8
  '';

  services.fwupd.enable = true;

  system.stateVersion = "23.11";
}
