{ fetchFromGitHub, buildDotnetModule, ... }:
let
  version = "1.8.24285.1";
in
buildDotnetModule {
  pname = "qbittorrent-cli";
  inherit version;

  src = fetchFromGitHub {
    owner = "fedarovich";
    repo = "qbittorrent-cli";
    tag = "v${version}";
    hash = "sha256-ZGK8nicaXlDIShACeF4QS0BOCZCN0T4JFtHuuFoXhBw=";
  };

  nugetDeps = ./deps.json;
  dotnetBuildFlags = [ "-f" "net6" ];
  dotnetInstallFlags = [ "-f" "net6" ];
  selfContainedBuild = true;

  projectFile = "src/QBittorrent.CommandLineInterface/QBittorrent.CommandLineInterface.csproj";
  executables = "qbt";
}

