{
  luaPackages,
  fetchgit,
  lua,
  callPackage,
  fetchurl,
  buildLuarocksPackage,
  luaOlder,
  enum,
  dbus_proxy,
}:
buildLuarocksPackage {
  pname = "upower_dbus";
  version = "0.3.0-3";
  knownRockspec =
    (fetchurl {
      url = "mirror://luarocks/upower_dbus-0.3.0-3.rockspec";
      sha256 = "0ypggb3g112kk2nm4kvkrhmi7m4qwjnlc39s4svpgfydazrqia0w";
    }).outPath;
  src = fetchgit (
    removeAttrs
      (builtins.fromJSON ''
        {
              "url": "https://github.com/stefano-m/lua-upower_dbus",
              "rev": "9cd11d08d96af66cc6c3be34f042014c87b3a9da",
              "date": "2017-11-05T15:06:39+00:00",
              "path": "/nix/store/9cjifvajwv27xg97m92v9vcivnlv15np-lua-upower_dbus",
              "sha256": "1mnnhc1g79gfgw3h6x6c3582psa3xnpfgvpkh9fay4n2kbw8y4hx",
              "fetchLFS": false,
              "fetchSubmodules": true,
              "deepClone": false,
              "leaveDotGit": false
            }
      '')
      [
        "date"
        "path"
      ]
  );

  disabled = with lua; (luaOlder "5.1");
  propagatedBuildInputs = [
    lua
    dbus_proxy
    enum
  ];

  meta = {
    homepage = "https://github.com/stefano-m/lua-upower_dbus";
    description = "Get power information with UPower and DBus";
    license.fullName = "Apache v2.0";
  };
}
