# naraos-nixos-flake

# TODO:
- [] Move all home-manager related files into a seperate module and makes a homes/nara@hades # Think of a better solution than declaring things twice

- [] Overhaul modules to avoid using the 'with' anti-pattern. [?] means recheck for enable = true; and with pkgs;
  - [?] apps
  - [x] cli-apps
  - [?] desktop
  - [?] hardware
  - [x] home
  - [x] services
  - [?] system
  - [?] tools
  - [x] user
  - [x] virt

- Upgrade hyprland
  - [x] better waybar theme.
  - [] hypridle
  - [] hyprlock
  - [] ags? (hyprpanel?)

- [x] Fix rofi-themes module.

- [] Move back to firefox.
  - [] Install BetterFox (https://github.com/yokoffing/BetterFox)

- [] Matugen on everything
  - [x] shell/terminal
  - [x] hyprland
  - [x] waybar
  - [] vscodium
  - [] firefox
  - [] discord
  - [] gtk
  - [] icons (with catppuccin color closest)

- [] Fix hades & zeus
  - [] hades
    - [] btrfs
    - [] lanzeboote
    - [] impermanance
  - [] zeus
    - [] impermanance

- [] Migrate homelab to nixos?