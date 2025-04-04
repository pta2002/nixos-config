{
  fetchurl,
  lua,
  buildLuarocksPackage,
  fetchgit,
  luaOlder,
  lgi,
}:
buildLuarocksPackage {
  pname = "dbus_proxy";
  version = "0.10.3-2";
  knownRockspec =
    (fetchurl {
      url = "mirror://luarocks/dbus_proxy-0.10.3-2.rockspec";
      sha256 = "0fhbj84vxd50lvk83isxin9hj70n9y0i62kx531695151lkr269h";
    }).outPath;
  src = fetchgit {
    rev = "c9253bde3fa5a64261953d1b196c57fabf9f8561";
    url = "https://github.com/stefano-m/lua-dbus_proxy";
    sha256 = "17ps8vz11lg2ylwpgw51avcdfsq6zlmcv7iw1hg3kpwf0jr3vzlr";
  };

  disabled = with lua; (luaOlder "5.1");
  propagatedBuildInputs = [
    lua
    lgi
  ];

  meta = {
    homepage = "https://github.com/stefano-m/lua-dbus_proxy";
    description = "Simple API around GLib's GIO:GDBusProxy built on top of lgi";
    license.fullName = "Apache v2.0";
  };
}
