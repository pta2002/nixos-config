{ pkgs }: with pkgs;
buildGoModule rec {
  pname = "yarr";
  version = "07d4845ae3c2b98b359fb9ff35797cdace4263ba";
  src = fetchFromGitHub {
    owner = "pta2002";
    repo = "yarr";
    rev = version;
    sha256 = "0ax8wvj8ls7i0pn98wdhdwqpnsa3w5vl4hz9h2j3k2930dsva9m1";
  };

  ldflags = [
    "-s"
    "-w"
    "-X"
    "main.Version=2.3"
    "-X"
    "main.GitHash=${version}"
  ];

  tags = [ "sqlite_foreign_keys" "release" ];

  subPackages = [ "src" ];
  vendorSha256 = null;

  postInstall = ''
    mv $out/bin/src $out/bin/yarr
  '';
}
