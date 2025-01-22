{
  pkgs,
  inputs,
  lib,
  ...
}:
let
  inherit (lib) getExe;
  inherit (lib.nos) enabled;
in
{
  imports = with inputs; [
    ./hardware-configuration.nix
    ./disk-configuration.nix
    nixos-hardware.nixosModules.common-gpu-amd
  ];

  nos = {
    apps = {
      bitwarden = enabled;
      bottles = enabled;
      chatterino = enabled;
      chromium = enabled // {
        makeDefaultBrowser = true;
      };
      clapper = enabled;
      discord = enabled;
      easyeffects = enabled // {
        preset = "perfect-eq";
      };
      emulators = {
        citra = enabled;
        dolphin = enabled;
        pcsx2 = enabled;
        rpcs3 = enabled;
        yuzu = enabled;
      };
      ente-auth = enabled;
      firefox = enabled // {
        betterfox = enabled;
      };
      launchers = {
        artix-games-launcher = enabled;
        heroic = enabled;
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
        rom-manager = enabled;
        steamos = enabled // {
          decky-loader = enabled;
        };
      };
      terminal = {
        alacritty = enabled;
        kitty = enabled // {
          themeFile = "Catppuccin-Mocha";
        };
      };
      vscode = enabled // {
        customCSS = enabled;
      };
      waydroid = enabled;
    };
    cli-apps = {
      ani-cli = enabled;
      fastfetch = enabled;
      lf = enabled;
      matugen = enabled;
      # neovim = enabled;
      # wallust = enabled // {
      #   addons.shell = enabled;
      # };
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
          };
          theme = {
            name = "catppuccin-mocha-blue-compact";
            package = pkgs.catppuccin-gtk.override {
              accents = [ "blue" ];
              variant = "mocha";
              size = "compact";
            };
            # name = "Skeuos-Blue-Dark";
            # package = pkgs.nos.skeuos-gtk-theme.override {
            #   colorScheme = { };
            # };
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
          # prism = enabled // {
          #   colorscheme = "catppuccin-mocha";
          # };
        };
        waybar = enabled;
        waypaper = enabled // {
          extraSettings.swww_transition_fps = 144;
        };
      };
      hyprland = enabled // {
        monitors = [
          {
            name = "DP-2";
            width = 2560;
            height = 1440;
            refreshRate = 144;
            position = "0x0";
            vrr = true;
            workspaces = [
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
          }
          {
            name = "DP-1";
            width = 2560;
            height = 1440;
            refreshRate = 144;
            position = "2560x0";
            vrr = true;
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
          {
            name = "DP-3";
            disabled = true;
          }
        ];
        extraSettings = {
          windowrulev2 = [
            "workspace 3 silent,class:(steam)"
            "workspace 4,tag:games"
            "workspace 11 silent,tag:browser"
            "workspace 12 silent,tag:discord"
            "workspace 13 silent,tag:music"
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
      openrgb = enabled // {
        # no-rgb = enabled;
      };
      ssd = enabled;
    };
    services = {
      # flatpak = enabled;
      openssh = enabled;
      syncthing = enabled;
    };
    system = {
      boot = {
        plymouth = enabled;
        systemd = enabled;
      };
      security = {
        doas = enabled;
      };
    };
    tools = {
      common = enabled // {
        fun = enabled;
      };
      devenv = enabled;
      direnv = enabled;
      disko = enabled;
      nix-ld = enabled;
      git = enabled;
      gpu-screen-recorder = enabled;
      qmk = enabled;
      zoxide = enabled;
    };
    virtualisation.qemu = enabled // {
      vfio = enabled;
    };
  };

  programs.corectrl = enabled // {
    gpuOverclock = enabled;
  };

  services.xserver.displayManager.setupCommands = ''
    ${getExe pkgs.xorg.xrandr} --output DP-1 --primary --mode 2560x1440 --output DP-2 --mode 2560x1440 --left-of DP-1 --output DP-3 --off
  '';

  system.stateVersion = "23.11";
}
