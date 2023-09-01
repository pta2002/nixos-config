{ pkgs, config, ... }: with pkgs;
let
  filebrowser = stdenv.mkDerivation {
    pname = "filebrowser";
    version = "2.23.0";
    src =
      if system == "aarch64-linux" then
        builtins.fetchurl
          {
            url = "https://github.com/filebrowser/filebrowser/releases/download/v2.23.0/linux-arm64-filebrowser.tar.gz";
            sha256 = "12gzxdz05476pzkacwgyihj5ix874v6as9ghigi646pwrziwsrr5";
          }
      else null;

    unpackPhase = ''
      mkdir -p "$out/bin"
      tar -xvf "$src" --directory "$out"
      mv "$out/filebrowser" "$out/bin/filebrowser"
    '';

    phases = [ "unpackPhase" ];
  };
in
{
  systemd.services.filebrowser = {
    description = "filebrowser";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "network-online.target" ];

    serviceConfig = {
      Restart = "on-failure";
      User = "transmission";
      Group = "transmission";
      ExecStart = "${filebrowser}/bin/filebrowser -p 8334 -d /var/lib/transmission/filebrowser.db";
      WorkingDirectory = "/mnt/data";
    };
  };

  services.argoWeb = {
    ingress."filestash.pta2002.com" = "http://localhost:8334";
  };
}
