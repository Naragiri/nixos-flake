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
    concatStringsSep
    ;
  inherit (lib.nos) recursiveMergeAttrs;
  cfg = config.nos.desktop.addons.waypaper;

in
{
  options.nos.desktop.addons.waypaper = {
    enable = mkEnableOption "Enable waypaper.";
    backend = mkOption {
      default = pkgs.swww;
      description = "The backend package for waypaper.";
      type = types.package;
    };
    extraSettings = mkOption {
      default = { };
      description = "Extra settings for config.ini";
      type = types.attrs;
    };
    finalPackage = mkOption {
      description = "The final waypaper package with backends.";
      readOnly = true;
      type = types.package;
    };
    onWallpaperChange = mkOption {
      default = [ ];
      description = "Commands to run when a wallpaper is changed.";
      type = types.listOf types.str;
    };
  };

  config = mkIf cfg.enable {
    nos.desktop.addons.waypaper.finalPackage = pkgs.waypaper.overrideAttrs (oldAttrs: {
      propagatedBuildInputs = oldAttrs.propagatedBuildInputs ++ [ cfg.backend ];
    });

    environment.systemPackages = [ cfg.finalPackage ];

    nos.home.configFile."waypaper/config.ini".text = lib.generators.toINI { } {
      Settings =
        let
          currentWallpaperFile = "/home/${config.nos.user.name}/.current_wallpaper";
        in
        recursiveMergeAttrs [
          {
            language = "en";
            folder = config.nos.desktop.addons.wallpapers.wallpapersDir;
            wallpaper = currentWallpaperFile;
            # backend = lib.getName (lists.findFirst (b: b != null) null cfg.backends);
            backend = lib.getName cfg.backend;
            monitors = "All";
            fill = "Fill";
            sort = "name";
            color = "#ffffff";
            subfolders = "False";
            number_of_columns = 3;
            # use_xdg_state = "True"; # Broken
            post_command =
              let
                waypaper-post_command = pkgs.writeScript "waypaper-post_command" ''
                  # Since nix files are readonly, make a workaround 
                  # to save the current wallpaper.
                  if ! [ "$1" == "${currentWallpaperFile}" ]; then 
                    ln -sf "$1" "${currentWallpaperFile}"
                  fi

                  ${concatStringsSep "\n" cfg.onWallpaperChange}
                '';
              in
              "${waypaper-post_command} $wallpaper";
            swww_transition_type = "grow";
            swww_transition_step = 10;
            swww_transition_duration = 1;
          }
          cfg.extraSettings
        ];
    };
  };
}
