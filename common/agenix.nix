{ config, ... }:
{
  age.rekey = {
    extraEncryptionPubkeys = [
      ../keys/laptop.pub
      ../keys/panda.pub
      ../keys/mars.pub
      ../keys/cloudy.pub
    ];

    masterIdentities = [
      "/home/pta2002/.ssh/id_ed25519"
    ];

    storageMode = "local";
    localStorageDir = ../. + "/secrets/rekeyed/${config.networking.hostName}";
  };
}
