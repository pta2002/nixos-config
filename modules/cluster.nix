{
  lib,
  config,
  inputs,
  ...
}:
let
  availableRoles = builtins.attrNames (builtins.readDir ../roles);
  cfg = config.cluster;

  # Mapping between host name and its roles
  rolesPerHost = lib.mapAttrs (
    _host: opts: lib.attrByPath [ "cluster" "roles" ] [ ] opts.config
  ) inputs.self.nixosConfigurations;

  # Mapping between roles and their hosts names
  hostsPerRole = lib.mergeAttrsList (
    lib.mapAttrsToList (host: roles: lib.genAttrs roles (lib.const [ host ])) rolesPerHost
  );
in
{
  options.cluster = {
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
