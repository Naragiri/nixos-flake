{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkIf
    mkEnableOption
    mkOption
    types
    getExe
    ;
  inherit (lib.nos.vscode) mkVscodeModule;

  cfg = config.nos.apps.vscode;

  # Copied from https://github.com/kubukoz/nix-config/blob/ad845b8dfd96ae53b1cb6be92687942e55641912/vscode/default.nix
  vscodeModule = mkVscodeModule {
    inherit (cfg) package;
    enable = true;
    enableExtensionUpdateCheck = false;
    enableUpdateCheck = false;
    userSettings = import ./settings.nix;
    keybindings = import ./keybindings.nix { inherit lib; };
    mutableExtensionsDir = false;
  };
in
{
  imports = [
    vscodeModule
    ./extensions.nix
    ./theme.nix
  ];

  options.nos.apps.vscode = {
    enable = mkEnableOption "Enable vscode with custom config.";
    customCSS = {
      enable = mkEnableOption "Enable custom css injection into vscode.";
      text = mkOption {
        default = builtins.readFile ./custom.css;
        description = "Custom css to inject into vscode.";
        type = types.nullOr types.lines;
      };
    };
    package = mkOption {
      default =
        if cfg.customCSS.enable then
          pkgs.vscodium.overrideAttrs (_: {
            # Credits for original extension: https://github.com/be5invis/vscode-custom-css/blob/master/src/extension.js
            postInstall =
              let
                custom-css = pkgs.writeText "custom-css" cfg.customCSS.text;
              in
              ''
                install -Dm644 ${custom-css} $out/lib/vscode/resources/app/out/vs/code/electron-sandbox/workbench/custom.css
                substituteInPlace $out/lib/vscode/resources/app/out/vs/code/electron-sandbox/workbench/workbench.html \
                  --replace "</head>" "<link rel="stylesheet" href="custom.css"></head>"
              '';
          })
        else
          pkgs.vscodium;
      description = "The vscode package.";
      type = types.package;
    };
  };

  config = mkIf cfg.enable {
    nos.home.extraOptions = {
      xdg.mimeApps.defaultApplications =
        let
          packageName = (builtins.parseDrvName cfg.package.name).name;
          fixedEditorName = {
            vscodium = "codium";
          };
          desktopFile = "${fixedEditorName.${packageName} or packageName}.desktop";
        in
        {
          "text/plain" = "${desktopFile}";
        };
    };

    environment.shellAliases = {
      "c" = "${getExe cfg.package} .";
    };
  };
}
