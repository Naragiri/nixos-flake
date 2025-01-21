{
  lib,
  config,
  pkgs,
  inputs,
  workspace-sh,
  screenshot-sh,
  ...
}:
let
  inherit (lib)
    getExe
    optionals
    map
    ;
  inherit (lib.nos) createUWSMCommand;
  inherit (inputs.nix-colors.colorschemes.${colorscheme}) palette;

  workspaceCount = 9;
  workspaceKeybinds = builtins.concatLists (
    builtins.genList (
      x:
      let
        id = toString (x + 1);
      in
      [
        "$mod, ${id}, exec, ${createUWSMCommand "${getExe workspace-sh} visit ${id}"}"
        "$mod SHIFT, ${id}, exec, ${createUWSMCommand "${getExe workspace-sh} move ${id}"}"
        "$mod CTRL, ${id}, exec, ${createUWSMCommand "${getExe workspace-sh} movesilent ${id}"}"
      ]
    ) workspaceCount
  );

  # TODO: Make colorscheme global.
  colorscheme = "catppuccin-mocha";
in
{
  "$browser" = "brave";
  "$fileManager" = "nemo";

  "$mod" = "SUPER";
  "$terminal" = "alacritty";

  animations = {
    enabled = true;
    animation = [
      "windows,1,5,smooth,popin"
      "fade,1,5,default"
      "workspaces,1,5,smooth,slidefade 30%"
    ];
    bezier = "smooth,0.23,1,0.32,1";
    first_launch_animation = true;
  };

  bind =
    [
      "$mod, B, exec, ${createUWSMCommand "$browser"}"
      "$mod, E, exec, ${createUWSMCommand "$fileManager"}"
      "$mod, Return, exec, ${createUWSMCommand "$terminal"}"
      "$mod, Q, killactive"
      "$mod ALT, Q, exit" # exec, uwsm stop" doesn't work atm.
      "$mod, V, togglefloating"
      "$mod SHIFT, V, fullscreen"
      "$mod SHIFT, period, exec, ${createUWSMCommand "${getExe config.nos.apps.vscode.package} /home/${config.nos.user.name}/Repos/naraos/nixos-flake"}"
      "$mod SHIFT, V, fullscreen"
      "$mod ALT, L, exec, ${createUWSMCommand "sleep 1 && hyprctl dispatch dpms off"}"
      ", XF86AudioRaiseVolume, exec, ${createUWSMCommand "wpctl set-volume @DEFAULT_SINK@ 5%+"}"
      ", XF86AudioLowerVolume, exec, ${createUWSMCommand "wpctl set-volume @DEFAULT_SINK@ 5%-"}"
    ]
    ++ [
      ", Print, exec, ${createUWSMCommand "${getExe screenshot-sh} area"}"
      "SHIFT, Print, exec, ${createUWSMCommand "${getExe screenshot-sh} active"}"
      "CTRL, Print, exec, ${createUWSMCommand "${getExe screenshot-sh} all"}"
    ]
    ++ [
      "$mod, right, movefocus, r"
      "$mod, left, movefocus, l"
      "$mod, down, movefocus, d"
      "$mod, up, movefocus, u"

      "$mod SHIFT, right, movewindow, r"
      "$mod SHIFT, left, movewindow, l"
      "$mod SHIFT, down, movewindow, d"
      "$mod SHIFT, up, movewindow, u"

      "$mod ALT, right, resizeactive, 100 0"
      "$mod ALT, left, resizeactive, -100 0"
      "$mod ALT, down, resizeactive, 0 100"
      "$mod ALT, up, resizeactive, 0 -100"
    ]
    ++ workspaceKeybinds;

  bindm = [
    "$mod, mouse:272, movewindow"
    "$mod, mouse:273, resizewindow"
  ];

  decoration = {
    rounding = 8;

    shadow = {
      enabled = true;
      range = 4;
      render_power = 3;
      color = "rgba(1a1a1aee)";
    };

    blur = {
      enabled = true;
      size = 5;
      passes = 2;
      vibrancy = 0.1696;
      xray = true;
      new_optimizations = true;
    };
  };
  exec-once =
    map createUWSMCommand [
      # "wl-paste -t text -w xclip -selection clipboard"
      "${getExe pkgs.wl-clip-persist} --clipboard both"
      "${getExe config.nos.desktop.addons.waybar.package}"
      "${getExe config.nos.desktop.addons.waypaper.finalPackage} --restore"
      "$browser"
      "vesktop"
      "spotify"
    ]
    ++ optionals (config.networking.hostName == "hades") [
      "steam"
      "spotify"
    ];

  general = {
    gaps_out = 8;

    border_size = 3;

    "col.active_border" =
      if config.nos.cli-apps.matugen.enable then "$primary" else "rgba(${palette.base0D}ee)";
    "col.inactive_border" =
      if config.nos.cli-apps.matugen.enable then "$inverse_primary" else "rgba(000000ee)";

    resize_on_border = false;

    #TODO: Enable for steam games.
    # allow_tearing = true;

    layout = "master";
  };

  input = {
    kb_layout = "us";
    follow_mouse = 1;
  };

  layerrule = [
    "dimaround,rofi"
  ];

  master = {
    new_status = "slave";
  };

  misc = {
    disable_hyprland_logo = true;
    disable_splash_rendering = true;
    force_default_wallpaper = 1;
    initial_workspace_tracking = 0;
    mouse_move_enables_dpms = true;
  };

  source = optionals config.nos.cli-apps.matugen.enable [ "colors.conf" ];

  windowrulev2 = [
    "tag +browser,class:(Brave-browser)"
    "tag +browser,class:(brave-browser)"
    "tag +browser,class:(zen-alpha)"

    "tag +pip,title:(Picture in picture)"
    "tag +pip,title:(Picture-In-Picture)"
    "tag +pip,title:(Picture-in-Picture)"
    "tag +discord,class:(vesktop)"
    "tag +vscode,class:(codium)"
    "tag +music,title:(Spotify Premium)"
    "tag +music,title:(Spotify Free)"
    "tag +music,class:(spotify)"
    "tag +terminal,class:(kitty)"

    "tag +games,title:(FINAL FANTASY XIV)"
    "tag +games,class:(genshinimpact.exe)"
    "tag +games,class:(Overwatch2.exe)"
    "tag +games,class:(^steam_app_\\d+$)"

    "opacity 0.98,tag:vscode"
    "opacity 0.98,tag:discord"

    "float,class:(openrgb)"
    "float,class:(pavucontrol)"
    "float,class:(nm-connection-editor)"
    "float,title:(^Bitwarden)"
    "float,class:(io.ente.auth)"
    "center,class:(openrgb)"
    "center,class:(pavucontrol)"
    "center,class:(nm-connection-editor)"
    "center,class:(io.ente.auth)"

    "float,class:(Rofi)"
    "opacity 0.9,class:(Rofi)"
    "center,class:(Rofi)"
    "dimaround,class:(Rofi)"

    "float,title:(gsr ui)"
    "center,title:(gsr ui)"
    "noanim,title:(gsr ui)"

    "opacity 0.98,class:(waypaper)"
    "float,class:(waypaper)"

    "float,tag:games"
    "maximize,tag:games"
    "fullscreen,tag:games"

    "float,tag:pip"
    "pin,tag:pip"
  ];
}
