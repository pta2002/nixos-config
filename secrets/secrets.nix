let
  keys = import ../ssh-keys.nix;
in
{
  "cloudflared.json.age".publicKeys = keys;
  "cert.pem.age".publicKeys = keys;
  "yarr.age".publicKeys = keys;
  "nextcloud.age".publicKeys = keys;
  "transmission.age".publicKeys = keys;
  "nginx.age".publicKeys = keys;
  "pietunnel.json.age".publicKeys = keys;
  "marstunnel.json.age".publicKeys = keys;
}
