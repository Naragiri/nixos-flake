{
  lib,
  config,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  inherit (lib.nos) enabled;
  cfg = config.nos.apps.terminal.kitty;
in
{
  options.nos.apps.terminal.kitty = {
    enable = mkEnableOption "Enable kitty.";
    themeFile = mkOption {
      default = null;
      description = "The theme to apply to kitty.";
      type = types.nullOr types.str;
    };
    extraConfig = mkOption {
      default = { };
      description = "Extra config to apply to kitty.";
      type = types.attrsOf types.str;
    };
  };

  config = mkIf cfg.enable {
    environment.shellAliases = {
      "ssh" = "kitten ssh";
    };

    nos.cli-apps.matugen.templates."kitty-colors" = {
      outputPath = "/home/${config.nos.user.name}/.config/kitty/colors.conf";
      text = ''
        cursor {{colors.on_surface.default.hex}}
        cursor_text_color {{colors.on_surface_variant.default.hex}}

        foreground            {{colors.on_surface.default.hex}}
        background            {{colors.surface.default.hex}}
        selection_foreground  {{colors.on_secondary.default.hex}}
        selection_background  {{colors.secondary_fixed_dim.default.hex}}
        url_color             {{colors.primary.default.hex}}
      '';
    };

    nos.home.extraOptions.programs.kitty = enabled // {
      inherit (cfg) themeFile;
      extraConfig = "include colors.conf";
      font = {
        name = "CaskaydiaCove Nerd Font";
        size = 16;
      };
      settings = cfg.extraConfig // {
        background_opacity = "0.85";
        confirm_os_window_close = 0;
        enable_audio_bell = "no";
        window_padding_width = 8;
      };
      shellIntegration = {
        enableZshIntegration = config.nos.system.shell.name == "zsh";
      };
    };
  };
}
