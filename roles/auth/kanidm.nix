{ config, pkgs, ... }:
let
  domain = "auth.pta2002.com";
  certPath = config.security.acme.certs."${domain}".directory;
in
{
  services.kanidm = {
    enableServer = true;
    package = pkgs.kanidmWithSecretProvisioning;

    serverSettings = {
      inherit domain;
      origin = "https://${domain}";

      # Weirdly chain/fullchain.pem don't seem to be correct?
      tls_chain = "${certPath}/cert.pem";
      tls_key = "${certPath}/key.pem";
    };

    provision = {
      enable = true;
      idmAdminPasswordFile = config.age.secrets.kanidmIdmAdmin.path;
      adminPasswordFile = config.age.secrets.kanidmAdmin.path;

      persons.pta2002 = {
        legalName = "Pedro Alves";
        displayName = "Pedro Alves";
        groups = [ "autobrr_users" ];
        mailAddresses = [ "pta2002@pta2002.com" ];
      };

      groups.autobrr_users.members = [ "pta2002" ];
    };
  };

  systemd.services.kanidm.requires = [ "acme-finished-${domain}.target" ];
  systemd.services.kanidm.after = [ "acme-finished-${domain}.target" ];

  age.secrets.kanidmIdmAdmin = {
    owner = "kanidm";
    group = "kanidm";
    mode = "400";
    file = ../../secrets/kanidm/idm_admin;
  };

  age.secrets.kanidmAdmin = {
    owner = "kanidm";
    group = "kanidm";
    mode = "400";
    file = ../../secrets/kanidm/admin;
  };

  security.acme.certs."${domain}" = {
    dnsProvider = "cloudflare";
    environmentFile = config.proxy.environmentFile;
    group = "kanidm";
    reloadServices = [ "kanidm.service" ];
  };

  # TODO! Would be neat if I could use the cloudflared CLI to set the DNS automatically...
  services.cloudflared.tunnels."${config.common.role.auth.name}-tunnel".ingress = {
    "${domain}" = {
      service = "https://localhost:8443";
      originRequest.originServerName = domain;
    };
  };

  common.backups.paths = [ "${config.services.kanidm.serverSettings.online_backup.path}" ];
}
