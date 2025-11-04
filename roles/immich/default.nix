{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.immich;
  redisSocket = config.services.redis.servers.immich.unixSocket;
in
{
  services.immich = {
    enable = true;
    database.enableVectors = false;
    database.enableVectorChord = true;
  };

  proxy.services.immich.addr = "localhost:${toString cfg.port}";

  # I'm using the container version of immich since NixOS doesn't update as
  # often, and it avoids having to compile OpenCV & co. with CUDA support,
  # since the CUDA Nix cache doesn't provide arm64 builds.

  # virtualisation.oci-containers.containers = {
  #   immich-server = {
  #     # Pulled on 2025-10-03
  #     imageFile = pkgs.dockerTools.pullImage {
  #       imageName = "ghcr.io/immich-app/immich-server";
  #       imageDigest = "sha256:d81f4af6a622d0955e5b8e3927da32b3ec882466a7ee8a26906d9cccad4364ca";
  #       hash = "sha256-fuPaYpj4301w1eMC42qYNNTBD8+PkTG/w0XQbnLuOqo=";
  #       finalImageName = "ghcr.io/immich-app/immich-server";
  #       finalImageTag = "release";
  #       arch = "arm64";
  #     };
  #
  #     image = "ghcr.io/immich-app/immich-server:release";
  #
  #     volumes = [
  #       "/var/lib/immich:/data"
  #       "/etc/localtime:/etc/localtime:ro"
  #       # Pass through redis and postgresql sockets
  #       "${redisSocket}:${redisSocket}"
  #       "/run/postgresql:/run/postgresql"
  #     ];
  #
  #     environment = {
  #       DB_URL = "postgresql://${cfg.database.user}@/${cfg.database.name}?host=/run/postgresql";
  #       DB_DATABASE_NAME = cfg.database.name;
  #
  #       REDIS_SOCKET = config.services.redis.servers.immich.unixSocket;
  #
  #       IMMICH_HOST = "0.0.0.0";
  #       IMMICH_TRUSTED_PROXIES = "127.0.0.1,::1";
  #     };
  #
  #     # Sadly this isn't enabled by default... Future work I guess!
  #     # https://github.com/immich-app/immich/discussions/10647
  #     # See here: https://elinux.org/Jetson_Zoo#ONNX_Runtime for override
  #     extraOptions = [
  #       "--pod=immich"
  #       "--device=nvidia.com/gpu=all"
  #     ];
  #
  #     devices = [ "nvidia.com/gpu=all" ];
  #   };
  #
  #   immich-machine-learning = {
  #     # TODO: Something's weird with nix-prefetch-docker so for now I'll just pull...
  #     # image = "ghcr.io/immich-app/immich-machine-learning:release";
  #     # TODO: This needs to be built by nix!
  #     image = "localhost/immich-machine-learning:jetson-release";
  #
  #     volumes = [ "model-cache:/cache" ];
  #
  #     extraOptions = [
  #       "--pod=immich"
  #       "--device=nvidia.com/gpu=all"
  #     ];
  #
  #     devices = [ "nvidia.com/gpu=all" ];
  #   };
  # };
  #
  # # Create the immich-pod so that immich-machine-learning and immich-server can talk to each other.
  # systemd.services.create-immich-pod = with config.virtualisation.oci-containers; {
  #   serviceConfig.Type = "oneshot";
  #   wantedBy = [
  #     "${containers.immich-server.serviceName}.service"
  #     "${containers.immich-machine-learning.serviceName}.service"
  #   ];
  #   after = [ "nvidia-container-toolkit-cdi-generator.service" ];
  #   script = ''
  #     ${pkgs.podman}/bin/podman pod exists immich || \
  #       ${pkgs.podman}/bin/podman pod create -n immich -p ${toString cfg.port}:2283 --device=nvidia.com/gpu=all
  #   '';
  # };
  #
  # # The podman

  #
  # services.postgresql = {
  #   enable = true;
  #   ensureDatabases = [ cfg.database.name ];
  #   ensureUsers = [
  #     {
  #       name = cfg.database.user;
  #       ensureDBOwnership = true;
  #       ensureClauses.login = true;
  #     }
  #   ];
  #
  #   # Allow root (docker!) to log in as the immich user
  #   identMap = ''
  #     immich root immich
  #   '';
  #
  #   authentication = ''
  #     local all immich ident map=immich
  #   '';
  #
  #   extensions = ps: [
  #     ps.pgvecto-rs
  #     ps.pgvector
  #     ps.vectorchord
  #   ];
  #   settings = {
  #     shared_preload_libraries = [
  #       "vectors.so"
  #       "vchord.so"
  #     ];
  #     search_path = "\"$user\", public, vectors";
  #   };
  # };
  #
  # systemd.services.postgresql.serviceConfig.ExecStartPost =
  #   let
  #     extensions = [
  #       "unaccent"
  #       "uuid-ossp"
  #       "cube"
  #       "earthdistance"
  #       "pg_trgm"
  #       "vectors"
  #       "vector"
  #       "vchord"
  #     ];
  #     sqlFile = pkgs.writeText "immich-pgvectors-setup.sql" ''
  #       ${lib.concatMapStringsSep "\n" (ext: "CREATE EXTENSION IF NOT EXISTS \"${ext}\";") extensions}
  #
  #       ALTER SCHEMA public OWNER TO ${cfg.database.user};
  #       ALTER SCHEMA vectors OWNER TO ${cfg.database.user};
  #       GRANT SELECT ON TABLE pg_vector_index_stat TO ${cfg.database.user};
  #
  #       ${lib.concatMapStringsSep "\n" (ext: "ALTER EXTENSION \"${ext}\" UPDATE;") extensions}
  #     '';
  #   in
  #   [
  #     ''
  #       ${lib.getExe' config.services.postgresql.package "psql"} -d "${cfg.database.name}" -f "${sqlFile}"
  #     ''
  #   ];
  #
  # services.redis.servers.immich = {
  #   enable = true;
  #   port = cfg.redis.port;
  # };
}
