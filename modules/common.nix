{ lib, config, ... }:
let
  roles = [
    "dns"
    "media"
    "data-host"
  ];

  cfg = config.common;
in
{
  options.common = {
    role = lib.listToAttrs
      (map
        (role: {
          name = role;
          value = {
            enabled = lib.mkOption {
              type = lib.types.bool;
              description = "Whether the role ${role} is enabled.";
              default = false;
            };

            name = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              description = "The hostname of the server with the role ${role}.";
              default = null;
            };
          };
        })
        roles);
  };
}
