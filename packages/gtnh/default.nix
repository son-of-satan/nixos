{
  lib,
  stdenv,
  fetchurl,
  fetchzip,
  unzip,
  jdk21,
  ...
}: let
  server-utilities = fetchurl {
    url = "https://github.com/GTNewHorizons/ServerUtilities/releases/download/1.0.2/ServerUtilities-1.0.2.jar";
    hash = "sha256-5sdOtCYm+Hg698Xlk4wZBsg43mRjMLd8LloAFN1YMb4=";
  };

  gtnh-server-src = fetchzip {
    url = "https://downloads.gtnewhorizons.com/ServerPacks/GT_New_Horizons_2.4.0_Server_Java_17-20.zip";
    hash = "sha256-2OtwaJuAa83u9iyMGKfeOUgJlqxsFtKVdTA4dliCBnQ=";
    stripRoot = false;
  };
in {
  mc-gtnh-server = stdenv.mkDerivation {
    pname = "mc-gtnh-server";
    version = "3.4.0";
    src = gtnh-server-src;
    nativeBuildInputs = [unzip];

    installPhase = ''
      mkdir -p $out/lib/mc-gtnh-server
      cp -rv --no-preserve mode $src/* $out/lib/mc-gtnh-server
      cp -v ${server-utilities} $out/lib/mc-gtnh-server/mods/

      mkdir -p $out/bin
      cat > $out/bin/mc-gtnh-server-start << EOF
      #!/bin/sh
      exec ${jdk21}/bin/java \$@ -Dfml.readTimeout=180 @java9args.txt nogui
      EOF

      cat > $out/bin/mc-gtnh-server-stop << EOF
      #!/bin/sh
      echo stop > "\$2"

      # Wait for the PID of the minecraft server to disappear before
      # returning, so systemd doesn't attempt to SIGKILL it.
      while kill -0 "\$1" 2> /dev/null; do
        sleep 1s
      done
      EOF

      chmod +x $out/bin/mc-gtnh-server-start
      chmod +x $out/bin/mc-gtnh-server-stop
    '';
  };
}
