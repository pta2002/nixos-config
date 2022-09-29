{ pkgs, modulesPath, ... }: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  environment.systemPackages = [ pkgs.git ];

  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev";
  };

  fileSystems."/boot" = { device = "/dev/disk/by-uuid/6AA5-BC42"; fsType = "vfat"; };
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

  users.users.pta2002 = {
    isNormalUser = true;
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [
	"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC2FuK78dZAIa4e60cSKuROmlYMcr/re9kAVyClsZ+IBEXDVEAR8m+f25jm4+UOasjVzDCetJPOxstmr25JItJeZjbH/WgMHUNo1ay2vq4qhQglgvEaa1M+EuiKcV6QhD+xcwC8eHKWdKreRUw/4iywwT1+52R4in5GB/3fZouDIID/kVbRq7m/h6pAanNqfXxQnDM7CHDELBgdxRYMYtQN48MUdA+ioE6Os7H0dHZ686qG/l3/iL/zzE35Ta08b0sX8H0CdCIfLWbbMLq0mXC3OlEmCQAWLa9OAfuznMrX/n6N8ZubdQP8rflgsdFzGdW5DO47LCPzP5L2H7aYIF7gynOVS7j/9UerEiJM6xCxBXSs3f1gBq+y/Xhtu/PJd8qsTbV7t0PKZ9y4EGS1rGZghtAX+Scb0HFBXX7B+9wfLtquV96O0P0Ds6rbRzGJSHCVhzc15rVZa6FQD5mki1k4v1FoFmIkcuTZiz1vP+ylUCv3R50yr201YPFqQi1JgCk= pta2002@mercury"
    ];
    extraGroups = [ "wheel" ];
    password = "";
  };

  nix = {
    settings.trusted-users = [ "root" "pta2002" ];
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
}

