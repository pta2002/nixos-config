pkgs: self: super: {
  luaPackages = super.luaPackages // rec {
    dbus_proxy = pkgs.callPackage (import ./dbus_proxy) {
      inherit (pkgs.luaPackages) lgi buildLuarocksPackage luaOlder;
    };

    enum = pkgs.callPackage (import ./enum) {
      inherit (pkgs.luaPackages) buildLuarocksPackage luaOlder;
    };

    upower_dbus = pkgs.callPackage (import ./upower_dbus) {
      inherit (pkgs.luaPackages) buildLuarocksPackage luaOlder dbus_proxy enum;
    };
  };
}
