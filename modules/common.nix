{ lib, config, ... }:
let
  roles = [
    "dns"
    "media"
  ];

  cfg = config.common;
in
{
  options.common = {
    role = lib.listToAttrs
      (map
        (role: {
          name = role;
          value = lib.mkOption
            {
              type = lib.types.bool;
              description = "Whether the role ${role} is enabled.";
              default = false;
            };
        })
        roles);
  };
}
