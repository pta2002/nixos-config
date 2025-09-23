{ pkgs, ... }:
{
  services.qbittorrent = {
    enable = true;

    user = "qbittorrent";
    group = "data";

    webuiPort = 9876;

    serverConfig = {
      Preferences.WebUI = {
        Username = "admin";
        Password_PBKDF2 = "@ByteArray(+oCodC4yCdKyEYKzkBs0Cg==:Srrfd7ftdJMav06xwYocajEm3PkpisVLrWQmie32IkcOo9/Y7jFkJG25zHYr3Tzvj3WdF2Egfk6NwNZmTNJOjQ==)";
        AlternativeUIEnabled = true;
        RootFolder = "${pkgs.vuetorrent}/share/vuetorrent";
      };
    };

    openFirewall = true;
  };
}
