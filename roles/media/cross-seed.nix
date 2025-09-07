{ config, ... }:
let
  user = "deluge";
  group = "data";
in
{
  services.cross-seed = {
    enable = true;
    inherit user group;
    settings = {
      dataDirs = [
        "/srv/media/tv"
        "/srv/media/movies"
      ];
      linkDirs = [ "/srv/media/torrents/links" ];
      torrentDir = "/var/lib/deluge/.config/deluge/state";
      outputDir = "/var/lib/deluge/output";
      linkType = "hardlink";
      matchMode = "partial";
      skipRecheck = true;
      maxDataDepth = 3;
      includeSingleEpisodes = true;
      seasonFromEpisodes = 0.5;
      fuzzySizeThreshold = 0.02;
      action = "inject";
      duplicateCategories = true;
      searchCadence = "1 day";
      excludeOlder = "2 weeks";
      excludeRecentSearch = "3 days";
    };

    settingsFile = config.age.secrets.cross-seed.path;
  };

  age.secrets.cross-seed = {
    rekeyFile = ../../secrets/cross-seed.json.age;
    owner = config.services.cross-seed.user;
    group = config.services.cross-seed.group;
  };
}
