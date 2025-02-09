{ lib, ... }:
let
  roles = [
    "dns"
    "media"
  ];
in
{
  options.common = {
    role = map
      (role: lib.mkOption {
        type = lib.types.bool;
        description = "Whether the role ${role} is enabled.";
        default = false;
      })
      roles;
  };
}
