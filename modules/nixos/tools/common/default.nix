{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf optionals;
  cfg = config.nos.tools.common;
in
{
  options.nos.tools.common = {
    enable = mkEnableOption "Enable common tools.";
    fun.enable = mkEnableOption "Enable fun tools.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages =
      with pkgs;
      [
        btop
        dig
        gparted
        gptfdisk
        killall
        man
        rar
        rsync
        tldr
        wget
        file
        unzip
        p7zip
        zip
      ]
      ++ optionals cfg.fun.enable [
        cava
        cmatrix
        cbonsai
      ];
  };
}
