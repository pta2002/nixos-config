let
  keys = import ../ssh-keys.nix;
in
{
  "cloudflared.json.age".publicKeys = keys;
  "cert.pem.age".publicKeys = keys;
  "yarr.age".publicKeys = keys;
  "nextcloud.age".publicKeys = keys;
}
