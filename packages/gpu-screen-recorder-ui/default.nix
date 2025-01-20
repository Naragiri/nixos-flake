{
  lib,
  pkgs,
  stdenv,
  libglvnd,
  pkg-config,
  meson,
  ninja,
  xorg,
  gpu-screen-recorder,
  makeWrapper,
  wrapperDir ? "/run/wrappers/bin",
  ...
}:
let
  pname = "gpu-screen-recorder-ui";
  source = (pkgs.callPackages ./generated.nix { }).${pname};

  gpu-screen-recorder-notification =
    let
      pname = "gpu-screen-recorder-notification";
      source = (pkgs.callPackages ./generated.nix { }).${pname};
    in
    stdenv.mkDerivation {
      inherit pname;
      inherit (source) src version;

      postPatch = ''
        substituteInPlace depends/mglpp/depends/mgl/src/gl.c \
          --replace-fail "libGL.so.1" "${lib.getLib libglvnd}/lib/libGL.so.1" \
          --replace-fail "libGLX.so.0" "${lib.getLib libglvnd}/lib/libGLX.so.0" \
          --replace-fail "libEGL.so.1" "${lib.getLib libglvnd}/lib/libEGL.so.1"
      '';

      nativeBuildInputs = [
        pkg-config
        meson
        ninja
      ];

      buildInputs = with xorg; [
        libX11
        libXrender
        libXrandr
        libXext
        libglvnd
      ];
    };
in
stdenv.mkDerivation rec {
  inherit pname;
  inherit (source) version src;

  postPatch = ''
    substituteInPlace depends/mglpp/depends/mgl/src/gl.c \
      --replace-fail "libGL.so.1" "${lib.getLib libglvnd}/lib/libGL.so.1" \
      --replace-fail "libGLX.so.0" "${lib.getLib libglvnd}/lib/libGLX.so.0" \
      --replace-fail "libEGL.so.1" "${lib.getLib libglvnd}/lib/libEGL.so.1"

    substituteInPlace extra/gpu-screen-recorder-ui.service \
      --replace-fail "ExecStart=${meta.mainProgram}" "ExecStart=$out/bin/${meta.mainProgram}"
  '';

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
    makeWrapper
  ];

  buildInputs = with xorg; [
    libX11
    libXrender
    libXrandr
    libXcomposite
    libXi
    libXcursor
    libglvnd
  ];

  mesonFlags = [
    # Handled by the module
    (lib.mesonBool "capabilities" false)
  ];

  postInstall =
    let
      gpu-screen-recorder-wrapped = gpu-screen-recorder.override {
        inherit wrapperDir;
      };
    in
    ''
      wrapProgram "$out/bin/${meta.mainProgram}" \
        --prefix PATH : "${wrapperDir}" \
        --suffix PATH : "${
          lib.makeBinPath [
            gpu-screen-recorder-wrapped
            gpu-screen-recorder-notification
          ]
        }"
    '';

  meta.mainProgram = "gsr-ui";
}
