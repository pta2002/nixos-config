{ config, ... }:
{
  age.rekey = {
    extraEncryptionPubkeys = [
      ../keys/laptop.pub
      ../keys/panda.pub
      ../keys/mars.pub
      ../keys/cloudy.pub
      ../keys/mac.pub
    ];

    masterIdentities = [
      {
        identity = ../yubikey-identity.txt;
        pubkey = "age1yubikey1qwp5e7kdrq7723a5ypppd7f37zwhldugu7qp2ur9qdfhz7ujfmsn272pqxs";
      }
    ];

    storageMode = "local";
    localStorageDir = ../. + "/secrets/rekeyed/${config.networking.hostName}";
    generatedSecretsDir = ../. + "/secrets/generated";
  };
}
