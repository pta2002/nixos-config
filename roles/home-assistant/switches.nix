{ pkgs, my-switches, ... }:
{
  systemd.services.switches = {
    description = "switches";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${my-switches.packages.${pkgs.system}.default}/bin/my-switches";
      Type = "simple";
      User = "switches";
      Group = "switches";
      Restart = "on-failure";
      RestartSec = "5s";
      DynamicUser = true;
    };
  };
}
