{ pkgs,  stdenv, fetchurl, unzip, graylog, autoPatchelfHook, nss, expat, libuuid, libXext, glib }:

with pkgs.lib;

stdenv.mkDerivation rec {
  name = "graylog-enterprise-${version}";
  pluginName = "graylog-plugin-enterprise";
  version = "3.3.4";

  src = fetchurl {
    url = "https://downloads.graylog.org/releases/graylog-enterprise/graylog-enterprise-plugins-${version}.tgz";
    sha256 = "186jscqjk6394q3wm9zbl2lwkgj8zsv53lqp74x66b3vq0nxkb95";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    nss
    expat
    libuuid
    libXext
    glib
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp plugin/graylog-plugin-enterprise-${version}.jar $out/bin/${pluginName}-${version}.jar
    cp bin/* $out/bin/
  '';

  meta = {
    homepage = https://www.graylog.org/graylog-enterprise-edition;
    platforms = graylog.meta.platforms;
    license = licenses.unfree;
    maintainers = [ maintainers.fadenb ];
  };
}
