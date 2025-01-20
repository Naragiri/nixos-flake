{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  inherit (lib.nos) enabled;
  cfg = config.nos.apps.spotify;
in
{
  imports = [ inputs.spicetify-nix.nixosModules.default ];

  options.nos.apps.spotify = {
    enable = mkEnableOption "Enable spotify.";
  };

  config = mkIf cfg.enable {
    programs.spicetify = enabled // {
      enabledExtensions =
        let
          spicetify-pkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
        in
        with spicetify-pkgs.extensions;
        [
          adblock
          beautifulLyrics
        ];
    };
  };
}
