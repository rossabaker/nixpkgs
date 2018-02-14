{ stdenv, fetchurl, dpkg, makeWrapper
, alsaLib, atk, cairo, cups, curl, dbus, expat, fontconfig, freetype, glib
, gnome2, libnotify, libxcb, nspr, nss, systemd, xorg }:

let

  version = "3.1.0";

  rpath = stdenv.lib.makeLibraryPath [
    alsaLib
    atk
    cairo
    cups
    curl
    dbus
    expat
    fontconfig
    freetype
    glib
    gnome2.GConf
    gnome2.gdk_pixbuf
    gnome2.gtk
    gnome2.pango
    libnotify
    libxcb
    nspr
    nss
    stdenv.cc.cc
    systemd

    xorg.libxkbfile
    xorg.libX11
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXrandr
    xorg.libXrender
    xorg.libXtst
    xorg.libXScrnSaver
  ] + ":${stdenv.cc.cc.lib}/lib64";

  src =
    if stdenv.system == "x86_64-linux" then
      fetchurl {
        url = "https://update.gitter.im/linux64/gitter_3.1.0_amd64.deb";
        sha512 = "b2888a2c9ed399102e2e80a2ec1ffafe093bdbe2f11d74753052c14841201cf586e0bb2a42ff8e67517d000a7c0b6f6aed30c32b3a7ecc683a18f8433b0bfa1c";
      }
    else
      throw "Gitter is not supported on ${stdenv.system}";

in stdenv.mkDerivation {
  name = "gitter-${version}";

  inherit src;

  dontBuild = true;
  buildInputs = [ dpkg makeWrapper ];
  
  unpackPhase = ''
    dpkg -x $src .
  '';
  
  installPhase = ''
    mkdir -p $out

    cp -r ./opt/Gitter/linux64 $out

    ls -lR $out

    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" "$out/linux64/Gitter"
    makeWrapper "$out/linux64/Gitter" "$out/bin/gitter" \
      --prefix LD_LIBRARY_PATH : "${rpath}"
  '';

  meta = with stdenv.lib; {
    description = "Desktop client for Gitter";
    homepage = https://gitter.im;
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
  };
}
