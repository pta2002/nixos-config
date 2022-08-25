{ fetchgit
, fetchurl
, lua
, luaOlder
, buildLuarocksPackage
}:
buildLuarocksPackage {
  pname = "enum";
  version = "0.1.1-1";
  knownRockspec = (fetchurl {
    url = "mirror://luarocks/enum-0.1.1-1.rockspec";
    sha256 = "00g6ib7lvnr3syw770f3mfq9mpdh3f1x5j2j24g43ckginv10ws8";
  }).outPath;
  src = fetchgit (removeAttrs
    (builtins.fromJSON ''{
            "url": "https://github.com/stefano-m/lua-enum",
            "rev": "414744076bd0edc3641cf670c2b0c43d84acf23c",
            "date": "2018-12-02T22:10:48+00:00",
            "path": "/nix/store/17a065pc2dv1hv6z6jvlpj8gkfrz86qy-lua-enum",
            "sha256": "1lz0v1sihxxlnn0z2x3wv8gr6xg4q5pw7da2x9hh9cgqgz4v4xib",
            "fetchLFS": false,
            "fetchSubmodules": true,
            "deepClone": false,
            "leaveDotGit": false
          }
           '') [ "date" "path" ]);

  disabled = with lua; (luaOlder "5.1");
  propagatedBuildInputs = [ lua ];

  meta = {
    homepage = "https://github.com/stefano-m/lua-enum";
    description = "Simulate enumerations in Lua";
    license.fullName = "Apache v2.0";
  };
}
