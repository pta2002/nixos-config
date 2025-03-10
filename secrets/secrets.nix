let
  keys = import ../ssh-keys.nix;
in
{
  "cloudflared.json.age".publicKeys = keys;
  "cloudflared-panda-tunnel.json.age".publicKeys = keys;
  "cert-panda.pem.age".publicKeys = keys;

  "cert.pem.age".publicKeys = keys;
  "yarr.age".publicKeys = keys;
  "nextcloud.age".publicKeys = keys;
  "deluge.age".publicKeys = keys;
  "flood-env.age".publicKeys = keys;
  "nginx.age".publicKeys = keys;
  "pietunnel.json.age".publicKeys = keys;
  "marstunnel.json.age".publicKeys = keys;
  "caddy-mars.age".publicKeys = keys;

  "tailscale-panda.age".publicKeys = keys;

  "rclone-config.age".publicKeys = keys;
  "restic-password.age".publicKeys = keys;

  "cross-seed.json.age".publicKeys = keys;
  "autobrr.age".publicKeys = keys;

  "arrs/prowlarrKey.age".publicKeys = keys;
  "arrs/sonarrKey.age".publicKeys = keys;
  "arrs/radarrKey.age".publicKeys = keys;
  "arrs/lidarrKey.age".publicKeys = keys;
  "arrs/readarrKey.age".publicKeys = keys;

  "autheliaJwt.age".publicKeys = keys;
  "autheliaEncryptionKey.age".publicKeys = keys;
  "autheliaUsers.yaml.age".publicKeys = keys;
  "autheliaRsa.pem.age".publicKeys = keys;
  "autheliaHmac.age".publicKeys = keys;

  "kanidm/admin".publicKeys = keys;
  "kanidm/idm_admin".publicKeys = keys;
}
