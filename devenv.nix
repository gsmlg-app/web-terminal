{ pkgs, lib, config, inputs, ... }:

let
  pkgs-stable = import inputs.nixpkgs-stable { system = pkgs.stdenv.system; };
  pkgs-unstable = import inputs.nixpkgs-unstable { system = pkgs.stdenv.system; };

  # Use same nixpkgs as Flutter to avoid ABI mismatches
  flutterPkgs = pkgs-unstable;

  # Flutter Linux build dependencies (dev outputs for pkg-config)
  linuxBuildInputs = with flutterPkgs; [
    gtk3.dev
    glib.dev
    pango.dev
    harfbuzz.dev
    cairo.dev
    gdk-pixbuf.dev
    atk.dev
    libepoxy.dev
    libsecret.dev
    xorg.libX11.dev
  ];
in
{
  env.GREET = "Web Terminal";

  packages = [
    pkgs-stable.git
    pkgs-stable.figlet
    pkgs-stable.lolcat
    pkgs-stable.watchman
    pkgs-stable.inotify-tools

    # Flutter Linux build dependencies (from same nixpkgs as Flutter)
    flutterPkgs.pkg-config
    flutterPkgs.gtk3
    flutterPkgs.libsecret
    flutterPkgs.cmake
    flutterPkgs.ninja
    flutterPkgs.clang
  ];

  env.PKG_CONFIG_PATH = lib.makeSearchPath "lib/pkgconfig" linuxBuildInputs;

  android = {
    enable = true;
    flutter.enable = true;
    flutter.package = pkgs-unstable.flutter;
  };

  scripts.hello.exec = ''
    figlet -w 120 $GREET | lolcat
  '';

  enterShell = ''
    hello
  '';

}
