{
  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.yarr = {
    url = "github:nkanaev/yarr";
    flake = false;
  };

  outputs = { self, flake-utils, yarr, nixpkgs }: flake-utils.lib.eachDefaultSystem (system:
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
    });
}
