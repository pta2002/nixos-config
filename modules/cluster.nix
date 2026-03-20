{
  lib,
  config,
  cluster,
  ...
}:
let
  availableRoles = lib.attrNames cluster.roles;
  cfg = config.cluster;

  # Mapping between roles and their hosts names
  hostsPerRole = lib.mapAttrs (_: v: v.hosts) cluster.roles;
in
{
  options.cluster = {
    deployHost = lib.mkOption {
      type = lib.types.str;
      description = "Hostname on which this machine can be reached";
    };

    roles = lib.mkOption {
      type = lib.types.listOf (lib.types.enum availableRoles);
      default = [ ];
      description = "List of roles for this host to take on";
    };

    role = lib.genAttrs availableRoles (role: {
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
    });
  };

  config.cluster = {
    roles = cluster.myRoles;

    role = lib.mkMerge (
      map (role: {
        ${role} = {
          enabled = builtins.elem role cfg.roles;
          name = lib.mkIf (builtins.length hostsPerRole.${role} == 1) (builtins.head hostsPerRole.${role});
        };
      }) availableRoles
    );
  };
}
