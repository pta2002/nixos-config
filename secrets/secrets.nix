let
  keys = import ../ssh-keys.nix;
in
{
  "cloudflared.json.age".publicKeys = keys;
  "cert.pem.age".publicKeys = keys;
  "yarr.age".publicKeys = keys;
  "nextcloud.age".publicKeys = keys;
  "deluge.age".publicKeys = keys;
  "nginx.age".publicKeys = keys;
  "pietunnel.json.age".publicKeys = keys;
  "marstunnel.json.age".publicKeys = keys;
  "caddy-mars.age".publicKeys = keys;

  "tailscale-panda.age".publicKeys = keys;

  "rclone-config.age".publicKeys = keys;
  "restic-password.age".publicKeys = keys;

  "cross-seed.json.age".publicKeys = keys;
  "autobrr.age".publicKeys = keys;
}
