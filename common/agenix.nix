{ config, ... }:
{
  age.rekey = {
    extraEncryptionPubkeys = [
      ../keys/panda.pub
      ../keys/mars.pub
      ../keys/cloudy.pub
      ../keys/mac.pub
      ../keys/thinkpad.pub
    ];

    masterIdentities = [
      {
        identity = ../yubikey-identity.pub;
        pubkey = "age1yubikey1qdcq69ac06n3kn5jwjkmustcja8nmk8qkwj3g7eemfjswnnrrq2fzjku5cc";
      }
    ];

    storageMode = "local";
    localStorageDir = ../. + "/secrets/rekeyed/${config.networking.hostName}";
    generatedSecretsDir = ../. + "/secrets/generated";
  };
}
