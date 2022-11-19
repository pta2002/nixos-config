{
  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.yarr = {
    url = "github:nkanaev/yarr";
    flake = false;
  };

  outputs = { self, flake-utils, yarr, nixpkgs, ... }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
    in
    with pkgs;
    rec {
      packages.yarr = buildGoModule
        rec {
          pname = "yarr";
          src = yarr;
          version = "2.3";

          ldflags = [
            "-s"
            "-w"
            "-X"
            "main.Version=${version}"
            "-X"
            "main.GitHash=unknown"
          ];

          tags = [ "sqlite_foreign_keys" "release" ];

          subPackages = [ "src" ];
          vendorSha256 = null;

          postInstall = ''
            mv $out/bin/src $out/bin/yarr
          '';
        };

      packages.gotosocial = stdenv.mkDerivation rec {
        pname = "gotosocial";
        version = "0.5.2";
        src =
          if system == "x86_64-linux" then
            builtins.fetchurl
              {
                url = "https://github.com/superseriousbusiness/gotosocial/releases/download/v0.5.2/gotosocial_${version}_linux_amd64.tar.gz";
                sha256 = "16rn0r53bj5vnwxmnhx0qcfwyjlq6znjn0wn90a1nvk40pjkpya4";
              } else
            builtins.fetchurl {
              url = "https://github.com/superseriousbusiness/gotosocial/releases/download/v0.5.2/gotosocial_${version}_linux_arm64.tar.gz";
              sha256 = "0n7h6pxk73l23j7qghiga2lss0bym38n6rs4ic590z45052id5r3";
            };

        unpackPhase = ''
          mkdir -p $out/bin
          tar -xvf $src --directory $out
          mv $out/gotosocial $out/bin/gotosocial
        '';

        phases = [ "unpackPhase" ];
      };
    });
}
