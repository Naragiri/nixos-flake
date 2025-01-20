{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (pkgs) vscode-extensions;
  inherit (lib.nos.vscode) configuredExtension;

  todo-tree = configuredExtension {
    extension = vscode-extensions.gruntfuggly.todo-tree;
  };

  material-icon-theme = configuredExtension {
    extension = vscode-extensions.pkief.material-icon-theme;
    settings = {
      "workbench.iconTheme" = "material-icon-theme";
      "material-icon-theme.hidesExplorerArrows" = true;
    };
  };

  indent-rainbow = configuredExtension {
    extension = vscode-extensions.oderwat.indent-rainbow;
    settings = {
      "indentRainbow.includedLanguages" = [
        "yaml"
        "dockercompose"
      ];
    };
  };

  direnv = configuredExtension {
    extension = vscode-extensions.mkhl.direnv;
  };

  rust-analyzer = configuredExtension {
    extension = vscode-extensions.rust-lang.rust-analyzer;
  };

  nix-ide = configuredExtension {
    extension = vscode-extensions.jnoortheen.nix-ide;
    settings = {
      "files.associations" = {
        "flake.lock" = "json";
      };
      "nix.enableLanguageServer" = true;
      "nix.hiddenLanguageServerErrors" = [
        "textDocument/definition"
        "textDocument/formatting"
      ];
      "nix.serverPath" = "${lib.getExe pkgs.nixd}";
      "nix.serverSettings" = {
        nixd = {
          formatting = {
            "command" = [ "${lib.getExe pkgs.nixfmt-rfc-style}" ];
          };
          nixpkgs = {
            "expr" =
              "import (builtins.getFlake \"/home/${config.nos.user.name}/Repos/naraos/nixos-flake\").inputs.nixpkgs { }";
          };
          options = {
            nixos = {
              "expr" =
                "(builtins.getFlake \"/home/${config.nos.user.name}/Repos/naraos/nixos-flake\").nixosConfigurations.${config.networking.hostName}.options";
            };
          };
        };
      };
    };
  };
in
{
  imports = [
    todo-tree
    material-icon-theme
    indent-rainbow
    direnv
    rust-analyzer
    nix-ide
  ];
}
