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
  cfg = config.nos.apps.terminal.alacritty;
in
{
  options.nos.apps.terminal.alacritty = {
    enable = mkEnableOption "Enable alacritty.";
    extraConfig = mkOption {
      default = { };
      description = "Extra config to apply to alacritty.";
      type = types.attrsOf types.str;
    };
  };

  config = mkIf cfg.enable {
    nos.cli-apps.matugen.templates."alacritty-colors" = {
      outputPath = "/home/${config.nos.user.name}/.config/alacritty/colors.toml";
      text = ''
        [colors.primary]
        background = '{{colors.background.default.hex}}'
        foreground = '{{colors.on_surface.default.hex}}'
         
        [colors.cursor]
        text = '{{colors.on_surface.default.hex}}'
        cursor = '{{colors.on_surface_variant.default.hex}}' 
         
        [colors.vi_mode_cursor]
        text = '{{colors.background.default.hex}}'
        cursor = '{{colors.primary.default.hex}}' 
         
        [colors.search.matches]
        foreground = '{{colors.surface_variant.default.hex}}' 
        background = '{{colors.tertiary.default.hex}}' 
         
        [colors.search.focused_match]
        foreground = '{{colors.surface_variant.default.hex}}' 
        background = '{{colors.primary.default.hex}}' 
         
        [colors.footer_bar]
        foreground = '{{colors.surface_variant.default.hex}}' 
        background = '{{colors.inverse_surface.default.hex}}' 
         
        [colors.hints.start]
        foreground = '{{colors.surface_variant.default.hex}}' 
        background = '{{colors.secondary.default.hex}}' 
         
        [colors.hints.end]
        foreground = '{{colors.surface_variant.default.hex}}' 
        background = '{{colors.secondary.default.hex}}' 
         
        [colors.selection]
        text = '{{colors.background.default.hex}}'
        background = '{{colors.primary.default.hex}}'
         
         
        [colors.normal]
        black = '#181818' 
        red = '{{colors.error.default.hex}}' 
        green = '{{colors.primary.default.hex}}' 
        yellow = '{{colors.inverse_primary.default.hex}}' 
        blue = '{{colors.primary.default.hex}}' 
        magenta = '{{colors.tertiary.default.hex}}' 
        cyan = '{{colors.secondary.default.hex}}' 
        white = '#BAC2DE' 
         
         
        [colors.bright]
        black = '#585B70' 
        red = '#F38BA8' 
        green = '#A6E3A1' 
        yellow = '#F9E2AF' 
        blue = '#89B4FA' 
        magenta = '#F5C2E7' 
        cyan = '#94E2D5' 
        white = '#A6ADC8' 
         
         
        [colors.dim]
        black = '#45475A' 
        red = '#F38BA8' 
        green = '#A6E3A1' 
        yellow = '#F9E2AF' 
        blue = '#89B4FA' 
        magenta = '#F5C2E7' 
        cyan = '#94E2D5' 
        white = '#BAC2DE' 
      '';
    };

    nos.home.extraOptions.programs.alacritty = enabled // {
      settings = cfg.extraConfig // {
        general.import = [ "colors.toml" ];
        window = {
          dynamic_padding = true;
          dimensions = {
            lines = 0;
            columns = 0;
          };
          padding = {
            x = 8;
            y = 8;
          };
          opacity = 0.85;
        };
        font = {
          normal = {
            family = "CaskaydiaCove Nerd Font";
            style = "Regular";
          };
          size = 16;
        };
      };
    };
  };
}
