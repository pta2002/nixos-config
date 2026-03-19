{ lib, config, ... }:
let
  availableRoles = builtins.attrNames (builtins.readDir ../roles);
  cfg = config.cluster;
in
{
  options.cluster = {
    roles = lib.mkOption {
      type = lib.types.listOf (lib.types.enum availableRoles);
      default = [ ];
      description = "List of roles for this host to take on";
    };

    role = lib.listToAttrs (
      map (role: {
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
      }) availableRoles
    );
  };

  config.cluster.role = lib.mkMerge (
    lib.map (role: {
      ${role}.enabled = true;
    }) cfg.roles
  );
}
