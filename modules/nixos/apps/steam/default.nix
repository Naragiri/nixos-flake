{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    types
    mkOption
    ;
  inherit (lib.nos) enabled;
  cfg = config.nos.apps.steam;

  pid-defer = inputs.pid-defer.packages.${pkgs.system}.default;

  # adapted from https://github.com/Cloudef/nixos-flake/blob/master/modules/steamdeck-experience.nix
  steam-mod = pkgs.steam.override {
    # privateTmp = false;
    extraPkgs = pkgs: [
      # steamdeck first boot wizard skip
      (pkgs.writeScriptBin "steamos-polkit-helpers/steamos-update" ''
        #!${pkgs.stdenv.shell}
        exit 7
      '')
      # switch to desktop
      (pkgs.writeScriptBin "steamos-session-select" ''
        #!${pkgs.stdenv.shell}
        kill $PPID
      '')
      pkgs.gamemode
    ];
  };

  steamos-gamescope = pkgs.writeShellApplication {
    name = "steamos-gamescope";
    runtimeInputs = [
      pid-defer
      pkgs.mangohud
      pkgs.ibus
      pkgs.inotify-tools
    ];
    text =
      let
        steam-payload = pkgs.writeScript "steam-payload" ''
          defer $$ ibus-daemon -d -r --panel=disable --emoji-extension=disable
          defer $$ mangoapp > "${cfg.steamos.configDir}/logs/mangoapp.log" 2>&1
          steam -gamepadui -steamos3 -steampal -steamdeck > "${cfg.steamos.configDir}/logs/steam.log" 2>&1
        '';

        plugin-patcher = pkgs.writeScript "plugin-patcher" ''
          tmpdir="$(mktemp -d)"
          trap 'rm -rf "$tmpdir"' EXIT

          patch_plug() {
            if [[ "$(file --dereference --mime "$@")" != *"binary" ]]; then
              # do not use -i because of the inotifywait
              local tmp; tmp="$(mktemp)"
              sed "s,/home/deck/homebrew,${cfg.steamos.configDir}/deckyloader,g" "$@" > "$tmp"
              sed -i "s,/home/deck/,$HOME/,g" "$tmp"
              if ! cmp --silent "$tmp" "$@"; then
                printf -- "patching '%s'\n" "$@"
                cp -f "$tmp" "$@"
              fi
              rm -f "$tmp"
            fi
          }

          # patch badly written plugins
          (grep -rlF "/home/deck/" "${cfg.steamos.configDir}/deckyloader/plugins" || true) | while read -r path; do patch_plug "$path"; done

          mkfifo "$tmpdir"/inotify.fifo
          defer $$ inotifywait --monitor -e create -e modify -e attrib -qr "${cfg.steamos.configDir}/deckyloader" --exclude "${cfg.steamos.configDir}/deckyloader/services" -o "$tmpdir"/inotify.fifo

          # has to be a copy, symlink makes PluginLoader look up files from wrong directory
          rm -f "${cfg.steamos.configDir}/deckyloader/services/PluginLoader"
          cp -f "${pkgs.nos.decky-loader}/bin/PluginLoader" "${cfg.steamos.configDir}/deckyloader/services/PluginLoader"
          (cd "${cfg.steamos.configDir}/deckyloader/services"; defer $$ steam-run ./PluginLoader &> "${cfg.steamos.configDir}/logs/deckyloader.log")

          # hack to automatically patch plugins and manage perms
          set +e
          while read -r dir event base; do
            file="$dir$base"
            if [[ "$event" == "ATTRIB"* ]]; then
              if [[ -d "$file" ]]; then
                [[ "$(stat -c '%a' "$file")" != "755" ]] && chmod -v 755 "$file"
              else
                [[ "$(stat -c '%a' "$file")" != "644" ]] && chmod -v 644 "$file"
              fi
            elif [[ -f "$file" ]]; then
              patch_plug "$file"
            fi
          done &> "${cfg.steamos.configDir}/logs/inotifywait.log" < "$tmpdir"/inotify.fifo
        '';
      in
      ''
        mkdir -p "${cfg.steamos.configDir}" "${cfg.steamos.configDir}/logs" ${cfg.steamos.configDir}/deckyloader/{services,plugins}

        # export XDG_SESSION_TYPE=x11
        export LIBSEAT_BACKEND="logind"
        export XKB_DEFAULT_LAYOUT="${config.console.keyMap}"

        TMP="$(mktemp -d)"
        trap 'rm -rf "$TMP"' EXIT

        export INTEL_DEBUG=norbc
        export mesa_glthread=true
        export SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS=0
        export SRT_URLOPEN_PREFER_STEAM=1
        export STEAM_USE_DYNAMIC_VRS=1

        export STEAM_GAMESCOPE_HAS_TEARING_SUPPORT=1
        export STEAM_GAMESCOPE_TEARING_SUPPORTED=1
        export STEAM_ENABLE_VOLUME_HANDLER=1
        export STEAM_GAMESCOPE_HDR_SUPPORTED=1
        export STEAM_GAMESCOPE_COLOR_TOYS=1
        export STEAM_GAMESCOPE_NIS_SUPPORTED=1
        export STEAM_GAMESCOPE_FANCY_SCALING_SUPPORT=1
        export STEAM_MULTIPLE_XWAYLANDS=1
        export STEAM_USE_MANGOAPP=1
        export STEAM_DISABLE_MANGOAPP_ATOM_WORKAROUND=1
        export STEAM_MANGOAPP_PRESETS_SUPPORTED=1
        export STEAM_MANGOAPP_HORIZONTAL_SUPPORTED=1

        export QT_IM_MODULE=steam
        export GTK_IM_MODULE=Steam

        export RADV_FORCE_VRS_CONFIG_FILE=$TMP/radv_vrs.XXXXXXXX
        mkdir -p "$(dirname "$RADV_FORCE_VRS_CONFIG_FILE")"
        echo "1x1" > "$RADV_FORCE_VRS_CONFIG_FILE"

        export MANGOHUD_CONFIGFILE=$TMP/mangohud.XXXXXXXX
        mkdir -p "$(dirname "$MANGOHUD_CONFIGFILE")"
        echo "no_display" > "$MANGOHUD_CONFIGFILE"

        ulimit -n 524288

        echo "${pkgs.nos.decky-loader.version}" > "${cfg.steamos.configDir}/deckyloader/services/.loader.version"
        touch "/home/${config.nos.user.name}/.steam/steam/.cef-enable-remote-debugging"
        chmod -R u=rwX,go=rX "${cfg.steamos.configDir}/deckyloader"

        defer $$ bash ${plugin-patcher}

        GAMESCOPE_COMMAND="gamescope -e \
          --prefer-output ${cfg.steamos.preferredOutput} \
          --hdr-enabled --hdr-itm-enable \
          -h ${toString cfg.steamos.internalResolution.height} -w ${toString cfg.steamos.internalResolution.width} \
          -H ${toString cfg.steamos.resolution.height} -W ${toString cfg.steamos.resolution.width} \
          -r ${toString cfg.steamos.maxRefreshRate} -o ${toString cfg.steamos.maxRefreshRate} \
          -F fsr -b -f --adaptive-sync \
          --expose-wayland --xwayland-count 2 \
          --steam -- ${steam-payload}"

        $GAMESCOPE_COMMAND > "${cfg.steamos.configDir}/logs/steam-gamescope.log" 2>&1

        # PluginLoader does not play nicely with SIGTERM
        pkill -9 PluginLoader
      '';
  };

  steamos-session =
    (pkgs.writeTextDir "share/wayland-sessions/steamos.desktop" ''
      [Desktop Entry]
      Name=SteamOS
      Comment=SteamOS Console Session
      Exec=${steamos-gamescope}/bin/steamos-gamescope
      Type=Application
    '').overrideAttrs
      (_: {
        passthru.providedSessions = [ "steamos" ];
      });
in
{
  options.nos.apps.steam = {
    enable = mkEnableOption "Enable steam.";
    steamos = {
      enable = mkEnableOption "Enable steamos session.";
      configDir = mkOption {
        type = types.path;
        default = "/home/${config.nos.user.name}/.steamos";
      };
      decky-loader.enable = mkEnableOption "Enable decky loader for steamos.";
      resolution = mkOption {
        type = types.attrs;
        default = {
          width = 3840;
          height = 2160;
        };
      };
      internalResolution = mkOption {
        type = types.attrs;
        default = {
          width = 2560;
          height = 1440;
        };
      };
      maxRefreshRate = mkOption {
        type = types.number;
        default = 120;
      };
      preferredOutput = mkOption {
        type = types.str;
        default = "DP-3";
      };
    };
  };

  config = mkIf cfg.enable {
    hardware.xone.enable = true;

    programs = {
      gamemode = enabled;
      gamescope = enabled // {
        capSysNice = !cfg.steamos.enable;
      };
      steam = {
        enable = true;
        package = if cfg.steamos.enable then steam-mod else pkgs.steam;
        remotePlay.openFirewall = true;
      };
    };

    environment.systemPackages = [
      pkgs.mangohud
      pkgs.protontricks
      pkgs.winetricks
      steamos-gamescope
    ];

    services.displayManager.sessionPackages = mkIf cfg.steamos.enable [
      steamos-session
    ];
  };
}
