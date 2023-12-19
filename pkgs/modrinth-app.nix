{ pkgs, appimageTools, ... }:
pkgs.stdenv.mkDerivation rec {
  name = "aptakube";
  version = "1.4.8-beta1";

  src = pkgs.fetchurl {
    url = "https://releases.aptakube.com/aptakube_${version}_amd64.deb";
    sha256 = "sha256-KzVCzZe6+IXnpag/ngdOvdzHg/szX/gJLNDhSfUvD8Y=";
  };

  buildInputs = [ pkgs.dpkg pkgs.tree ];

  sourceRoot = ".";
  unpackCmd = "dpkg-deb -x $src .";

  dontConfigure = true;
  dontBuild = true;


  installPhase = ''
    mkdir -p $out/bin
    cp  usr/bin/aptakube $out/bin
  '';
  preFixup =
    let
      # found all these libs with `patchelf --print-required` and added them so that they are dynamically linked
      libPath = lib.makeLibraryPath [
        pkgs.webkitgtk
        pkgs.gtk3
        pkgs.pango
        pkgs.cairo
        pkgs.gdk-pixbuf
        pkgs.glib
        pkgs.libsoup
      ];
    in
    ''
      patchelf \
        --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        --set-rpath "${libPath}" \
        $out/bin/aptakube
    '';

  meta = with lib; {
    homepage = "https://modrinth.com/app";
    description = "The Modrinth App is a unique, open source launcher that allows you to play your favorite mods, and keep them up to date, all in one neat little package.";
    license = licenses.unfree;
    platforms = platforms.linux;
  };
}
