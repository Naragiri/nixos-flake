{
  pkgs,
  stdenv,
  gnumake,
  inkscape,
  sassc,
# variants ? [ "Dark" ],
# colorVariants ? [ "Blue" ],
}:
let
  pname = "skeuos-gtk-theme";
  source = (pkgs.callPackages ./generated.nix { }).${pname};

  # validVariants = [
  #   "Dark"
  #   "Light"
  # ];

in
# validColorVariants = [
#   "Blue"
#   "Green"
#   "Red"
#   "Yellow"
#   "Black"
#   "Brown"
#   "Cyan"
#   "Grey"
#   "Magenta"
#   "Orange"
#   "Tea"
#   "Violet"
#   "White"
# ];
stdenv.mkDerivation {
  inherit pname;
  inherit (source) version src;

  dontConfigure = true;

  nativeBuildInputs = [
    gnumake
    inkscape
    sassc
  ];

  makeFlags = [ "PREFIX=$(out)" ];
}
