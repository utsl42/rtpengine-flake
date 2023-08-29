{ lib, stdenv, pkgs, fetchFromGitHub }:
let
  version = "11.4.1.4";
  src = fetchFromGitHub {
    owner = "sipwise";
    repo = "rtpengine";
    #    ref = "mr11.4.1.4";
    rev = "e6f052590b901423618d1ea37c26ce7398b9f639";
    sha256 = "sha256-VSX4op/g7kq93hev4gtlCaA4jksx2j6Ap13Ev9FTRsI=";
  };
  rtpengine = stdenv.mkDerivation rec {
    inherit src;
    inherit version;
    pname = "rtpengine";

    nativeBuildInputs = with pkgs; [ pkg-config gperf perl pandoc ];
    buildInputs = with pkgs; [ openssl libmysqlclient hiredis glib json-glib zlib libpcap pcre ffmpeg-headless libopus spandsp3 libevent libwebsockets xmlrpc_c curl libxml2 iptables systemd perl ];

    patchPhase = ''
      patchShebangs utils/const_str_hash
      patchShebangs utils/build_test_wrapper
    '';
    buildPhase = ''
      export DESTDIR=$out
      make
    '';
    installPhase = ''
      export DESTDIR=$out
      make install
      mv $out/usr/* $out/
      rm $out/bin/rtpengine-ng-client
      rm $out/share/man/man1/rtpengine-ng-client.1
    '';

    meta = with lib; {
      description = "The Sipwise media proxy";
      homepage = "https://";
      license = licenses.gpl3;
      platforms = platforms.unix;
    };
  };
in
 rtpengine

