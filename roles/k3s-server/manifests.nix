{ config, lib, ... }:
{
  services.k3s.manifests = {
    https.content = [
      {
        apiVersion = "cert-manager.io/v1";
        kind = "ClusterIssuer";
        metadata.name = "letsencrypt-prod";
        spec.acme = {
          email = config.security.acme.defaults.email;
          server = config.security.acme.defaults.server;
          privateKeyRef.name = "letsencrypt-prod";
          solvers = [
            {
              http1.ingress.class = "traefik";
            }
          ];
        };
      }
      {
        apiVersion = "helm.cattle.io/v1";
        kind = "HelmChartConfig";
        metadata = {
          name = "traefik";
          namespace = "kube-system";
        };
        spec.valuesContent = (lib.generators.toYAML { }) {
          ports.web.redirections.entryPoint = {
            to = "websecure";
            scheme = "https";
            permanent = true;
          };
        };
      }
    ];

    zigbee.content = [
      {
        apiVersion = "akri.sh/v0";
        kind = "Configuration";
        metadata.name = "akri-zigbee";
        spec = {
          capacity = 1;
          discoveryHandler = {
            discoveryDetails = (lib.generators.toYAML { }) {
              groupRecursive = true;
              udevRules = [ ''ATTRS{idVendor}=="0451", ATTRS{idProduct}=="16a8"'' ];
            };
            name = "udev";
          };
        };
      }
    ];
  };
}
