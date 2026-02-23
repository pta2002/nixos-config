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
        pubkey = "age1yubikey1qwy0nkvhkh8rq5w8qe4ccm8updw2vdegx5u5775entz5gx9rng73c489k9d";
      }
    ];

    storageMode = "local";
    localStorageDir = ../. + "/secrets/rekeyed/${config.networking.hostName}";
    generatedSecretsDir = ../. + "/secrets/generated";
  };
}
