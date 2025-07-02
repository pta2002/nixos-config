{ lib, pkgs, ... }:
{
  services.k3s.autoDeployCharts = {
    cert-manager = {
      package = pkgs.fetchurl {
        url = "https://charts.jetstack.io/charts/cert-manager-v1.18.2.tgz";
        hash = "sha256-2t33r3sfDqqhDt15Cu+gvYwrB4MP6/ZZRg2EMhf1s8U=";
      };
      # So that the helm chart installs the CRDs.
      values.crds.enabled = true;
    };
    akri = {
      package = pkgs.fetchurl {
        url = "https://project-akri.github.io/akri/akri-0.13.8.tgz";
        hash = "sha256-fgFDFXM493U9m1uILvwO3F9D5NVINgS4VEwFAI81r7o=";
      };

      values = {
        kubernetesDistro = "k3s";
        udev.discovery.enabled = true;
      };
    };
  };
}
