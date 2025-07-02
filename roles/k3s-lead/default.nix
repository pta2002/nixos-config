{ lib, ... }:
{
  # As this is the main cluster, this one is responsible for initializing it.
  services.k3s.clusterInit = lib.mkForce true;
  services.k3s.serverAddr = lib.mkForce "";
}
