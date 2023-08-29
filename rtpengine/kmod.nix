{ lib, stdenv, pkgs, fetchFromGitHub, kernel, kmod }:
stdenv.mkDerivation rec {
    version = "11.4.1.4";
    pname = "rtpengine-${version}-${kernel.version}";
  src = fetchFromGitHub {
    owner = "sipwise";
    repo = "rtpengine";
    #    ref = "mr11.4.1.4";
    rev = "e6f052590b901423618d1ea37c26ce7398b9f639";
    sha256 = "sha256-VSX4op/g7kq93hev4gtlCaA4jksx2j6Ap13Ev9FTRsI=";
  };

    hardeningDisable = [ "pic" "format" ];
    nativeBuildInputs = kernel.moduleBuildDependencies;

    makeFlags = [
      "KERNELRELEASE=${kernel.modDirVersion}"
      "KSRC=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
      "INSTALL_MOD_PATH=$(out)"
    ];

    sourceRoot = "source/kernel-module";

    buildPhase = ''
      export KSRC=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build
      export DESTDIR=$out
      make modules
    '';

    installPhase = ''
      install -D xt_RTPENGINE.ko $out/lib/modules/${kernel.modDirVersion}/extra/rtpengine/xt_RTPENGINE.ko
    '';
    meta = with lib; {
      description = "A kernel module for RTPEngine";
      homepage = "https://github.com/";
      license = licenses.gpl2;
      platforms = platforms.linux;
    };
  }
