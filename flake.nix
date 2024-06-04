{
  description = "NaraOS NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # i hate nintendo.
    yuzu-fix.url =
      "github:nixos/nixpkgs/d89fdbfc985022d183073cb52df4d35b791d42cf";

    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.3.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-ld = {
      url = "github:Mic92/nix-ld";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    nixvim.url = "github:nix-community/nixvim/nixos-23.11";

    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    let
      lib = inputs.snowfall-lib.mkLib {
        inherit inputs;
        src = ./.;

        snowfall = {
          meta = {
            name = "naraos-nixos-flake";
            title = "NaraOS NixOS";
          };

          namespace = "nos";
        };
      };
    in (lib.mkFlake {
      channels-config = {
        allowUnfree = true;
        permittedInsecurePackages = [ "electron-25.9.0" ];
      };

      systems.hosts.hades.modules = [ ./disks/hades.nix ];

      systems.hosts.zeus.modules = [ ./disks/zeus.nix ];

      templates = import ./templates { };

      outputs-builder = channels: {
        checks.pre-commit-check =
          inputs.pre-commit-hooks.lib.${channels.nixpkgs.system}.run {
            src = ./.;
            hooks = { treefmt.enable = true; };
          };
      };
    });
}
