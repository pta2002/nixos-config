{ config, pkgs, ... }:
let
  storeDeps = pkgs.runCommand "store-deps" { } ''
    mkdir -p $out/bin
    for dir in ${
      toString [
        pkgs.coreutils
        pkgs.findutils
        pkgs.gnugrep
        pkgs.gawk
        pkgs.git
        pkgs.nix
        pkgs.bash
        pkgs.jq
        pkgs.nodejs
        pkgs.curl
        pkgs.python3
      ]
    }; do
      for bin in "$dir"/bin/*; do
        ln -s "$bin" "$out/bin/$(basename "$bin")"
      done
    done

    # Add SSL CA certs
    mkdir -p $out/etc/ssl/certs
    cp -a "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt" $out/etc/ssl/certs/ca-bundle.crt
  '';
  forgejoUrl = "https://forgejo.p.pta2002.com";
in
{
  # https://git.clan.lol/clan/clan-infra/src/branch/main/modules/web01/gitea/actions-runner.nix
  virtualisation.podman.enable = true;

  age.secrets.forgejoToken.rekeyFile = ../../secrets/forgejo-token.age;

  systemd.services.forgejo-runner-nix-image = {
    wantedBy = [ "multi-user.target" ];
    after = [ "podman.service" ];
    requires = [ "podman.service" ];
    path = [
      config.virtualisation.podman.package
      pkgs.gnutar
      pkgs.shadow
      pkgs.getent
    ];
    # we also include etc here because the cleanup job also wants the nixuser to be present
    script = ''
      set -eux -o pipefail
      mkdir -p etc/nix

      # Create an unpriveleged user that we can use also without the run-as-user.sh script
      touch etc/passwd etc/group
      groupid=$(cut -d: -f3 < <(getent group nixuser))
      userid=$(cut -d: -f3 < <(getent passwd nixuser))
      groupadd --prefix $(pwd) --gid "$groupid" nixuser
      emptypassword='$6$1ero.LwbisiU.h3D$GGmnmECbPotJoPQ5eoSTD6tTjKnSWZcjHoVTkxFLZP17W9hRi/XkmCiAMOfWruUwy8gMjINrBMNODc7cYEo4K.'
      useradd --prefix $(pwd) -p "$emptypassword" -m -d /tmp -u "$userid" -g "$groupid" -G nixuser nixuser

      cat <<NIX_CONFIG > etc/nix/nix.conf
      accept-flake-config = true
      experimental-features = nix-command flakes
      NIX_CONFIG

      cat <<NSSWITCH > etc/nsswitch.conf
      passwd:    files mymachines systemd
      group:     files mymachines systemd
      shadow:    files

      hosts:     files mymachines dns myhostname
      networks:  files

      ethers:    files
      services:  files
      protocols: files
      rpc:       files
      NSSWITCH

      # list the content as it will be imported into the container
      tar -cv . | tar -tvf -
      tar -cv . | podman import - forgejo-runner-nix
    '';
    serviceConfig = {
      RuntimeDirectory = "forgejo-runner-nix-image";
      WorkingDirectory = "/run/forgejo-runner-nix-image";
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };

  users.users.nixuser = {
    group = "nixuser";
    description = "Used for running nix ci jobs";
    home = "/var/empty";
    isSystemUser = true;
  };
  users.groups.nixuser = { };

  systemd.services.gitea-runner-nix = {
    after = [ "forgejo-runner-nix-image.service" ];
    requires = [ "forgejo-runner-nix-image.service" ];

    serviceConfig = {
      # Hardening (may overlap with DynamicUser=)
      # The following options are only for optimizing output of systemd-analyze
      AmbientCapabilities = "";
      CapabilityBoundingSet = "";
      # ProtectClock= adds DeviceAllow=char-rtc r
      DeviceAllow = "";
      NoNewPrivileges = true;
      PrivateDevices = true;
      PrivateMounts = true;
      PrivateTmp = true;
      PrivateUsers = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectSystem = "strict";
      RemoveIPC = true;
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      UMask = "0066";
      ProtectProc = "invisible";
      SystemCallFilter = [
        "~@clock"
        "~@cpu-emulation"
        "~@module"
        "~@mount"
        "~@obsolete"
        "~@raw-io"
        "~@reboot"
        "~@swap"
        # needed by go?
        #"~@resources"
        "~@privileged"
        "~capset"
        "~setdomainname"
        "~sethostname"
      ];
      SupplementaryGroups = [ "podman" ];
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_UNIX"
        "AF_NETLINK"
      ];

      # Needs network access
      PrivateNetwork = false;
      # Cannot be true due to Node
      MemoryDenyWriteExecute = false;

      # The more restrictive "pid" option makes `nix` commands in CI emit
      # "GC Warning: Couldn't read /proc/stat"
      # You may want to set this to "pid" if not using `nix` commands
      ProcSubset = "all";
      # Coverage programs for compiled code such as `cargo-tarpaulin` disable
      # ASLR (address space layout randomization) which requires the
      # `personality` syscall
      # You may want to set this to `true` if not using coverage tooling on
      # compiled code
      LockPersonality = false;

      # Note that this has some interactions with the User setting; so you may
      # want to consult the systemd docs if using both.
      DynamicUser = true;
    };
  };

  services.gitea-actions-runner = {
    package = pkgs.forgejo-actions-runner;

    instances = {
      native = {
        enable = true;
        name = config.networking.hostName;
        url = forgejoUrl;
        tokenFile = config.age.secrets.forgejoToken.path;
        labels = [ "native:host" ];
      };

      debian-latest-docker = {
        enable = true;
        name = "${config.networking.hostName}-docker";
        url = forgejoUrl;
        tokenFile = config.age.secrets.forgejoToken.path;
        labels = [
          "debian-latest:docker://node:18-bullseye"
          "ubuntu-latest:docker://node:18-bullseye"
        ];
      };

      nix = {
        enable = true;
        name = "${config.networking.hostName}-nix-runner";
        url = forgejoUrl;
        tokenFile = config.age.secrets.forgejoToken.path;
        labels = [
          "nix-${pkgs.system}:docker://forgejo-runner-nix"
          "nix:docker://forgejo-runner-nix"
        ];
        settings = {
          container.options = "-e NIX_BUILD_SHELL=/bin/bash -e PAGER=cat -e PATH=/bin -e SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt -v /nix:/nix -v ${storeDeps}/bin:/bin -v ${storeDeps}/etc/ssl:/etc/ssl --user nixuser";
          container.network = "host";
          container.valid_volumes = [
            "/nix"
            "${storeDeps}/bin"
            "${storeDeps}/etc/ssl"
          ];
        };
      };
    };
  };
}
