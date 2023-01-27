{ pkgs, modulesPath, inputs, ... }: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./modules/argoweb.nix
    ./modules/yarr.nix
    ./modules/nextcloud.nix
    ./modules/files.nix
    ./modules/transmission.nix
    ./modules/mastodon.nix
    # ./modules/synapse.nix
    ./modules/fava.nix
    ./modules/vaultwarden.nix

    ./modules/jellyfin.nix
  ];

  environment.systemPackages = with pkgs; [
    git
    docker-compose
  ];

  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev";
  };

  fileSystems."/boot" = { device = "/dev/disk/by-uuid/8F94-DEC6"; fsType = "vfat"; };
  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "xen_blkfront" ];
  boot.initrd.kernelModules = [ "nvme" ];
  fileSystems."/" = { device = "/dev/sda1"; fsType = "ext4"; };

  boot.cleanTmpDir = true;
  zramSwap.enable = true;
  networking.hostName = "cloudy";

  environment.shells = with pkgs; [ bash fish ];

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
  };

  virtualisation.docker.enable = true;

  users.users.pta2002 = {
    isNormalUser = true;
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = import ./ssh-keys.nix;
    extraGroups = [ "wheel" "argoweb" "docker" ];
    password = "";
  };

  security.sudo.extraRules = [
    {
      users = [ "pta2002" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  nix = {
    settings.trusted-users = [ "root" "pta2002" ];
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  system.stateVersion = "22.11";

  nixpkgs.config.allowUnfree = true;

  services.tailscale.enable = true;

  # Stuff for argo
  age.secrets.cloudflared = {
    file = ../secrets/cloudflared.json.age;
    owner = "argoweb";
  };

  age.secrets.cert = {
    file = ../secrets/cert.pem.age;
    owner = "argoweb";
  };
}

