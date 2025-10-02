{ config, ... }: {
  services.immich = {
    enable = true;
    openFirewall = true;
    # TODO: The machine-learning package indirectly requires NCCL, so it's not compiling on Jetson.
    # It also gives some weird compilation errors, so let's just disable it for now...
    machine-learning.enable = false;
  };

  proxy.services.immich = {
    addr = "localhost:${toString config.services.immich.port}";
  };
}
