let
  keys = import ../ssh-keys.nix;
in
{
  "cloudflared.json.age".publicKeys = keys;
  "cert.pem.age".publicKeys = keys;
}
