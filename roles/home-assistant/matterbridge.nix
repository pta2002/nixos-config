{ pkgs, ... }:
let
  # TODO: Use these, instead of the container image.
  matterbridge-zigbee2mqtt = pkgs.buildNpmPackage {
    pname = "matterbridge-zigbee2mqtt";
    version = "2.2.1";

    src = pkgs.fetchFromGitHub {
      owner = "Luligu";
      repo = "matterbridge-zigbee2mqtt";
      rev = "2.2.1";
      hash = "sha256-OgG7jwYJLq0aPL8O8P/Z+77HvjIr6u+ry5vWnyy0tNE=";
    };

    npmDepsHash = "sha256-gMIQpDXvAFfvuRwF5SFL2N47I3/gVm80uFH7kBEVbiw=";
    dontNpmBuild = true;
  };

  # TODO: Needs to be able to install plugins, somehow.
  matterbridge = pkgs.buildNpmPackage {
    pname = "matterbridge";
    version = "git";

    src = pkgs.fetchFromGitHub {
      owner = "Luligu";
      repo = "matterbridge";
      rev = "4ce3a4d27b47480db29698e62697a5907fa4e5ab";
      hash = "sha256-jtZO86hPQSrCx0Sb2bL9v8ImMZQ4S671w2dsChKCDkY=";
    };

    npmDepsHash = "sha256-IRBo2wsYbA6XMk4jKLeFFxyOWChfxuABiU5AjjwRwns=";
  };
in
{
  virtualisation.oci-containers.containers.matterbridge = {
    image = "luligu/matterbridge";
    extraOptions = [ "--network=host" ];
    volumes = [
      "matterbridge-plugin:/root/Matterbridge"
      "matterbridge-config:/root/.matterbridge"
    ];
  };

  networking.firewall = {
    # Matter listens on port 5540.
    allowedTCPPorts = [ 5540 ];
    allowedUDPPorts = [ 5540 ];
  };
}
