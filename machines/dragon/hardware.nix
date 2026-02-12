{
  pkgs,
  lib,
  ...
}:
{
  hardware.facter.reportPath = ./facter.json;

  boot.kernelPackages = pkgs.linuxPackagesFor pkgs.kernel_radxa;
  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = true;

  boot.initrd.availableKernelModules = [
    # Qualcomm SPMI bus and PMIC
    "spmi-pmic-arb"
    "qcom-spmi-pmic"
    # Qualcomm RPMh regulator stack
    "qcom-rpmh-regulator"
    "qcom-rpmh"
    # Qualcomm USB controllers
    "dwc3"
    "dwc3-qcom"
    # Qualcomm USB PHYs
    "phy-qcom-qmp-usb"
    "phy-qcom-snps-femto-v2"
    # xHCI host controller (platform/devicetree variant)
    "xhci_hcd"
    "xhci_plat_hcd"
    # USB mass storage
    "usb_storage"
    "uas"
    # PCIe PHY (needed early for pipe_clk, otherwise PCIe defers for ~3 min)
    "phy-qcom-qmp-pcie"
    # NIC driver
    "r8169"
  ];

  # No TPM hardware - prevent 90s timeout waiting for /dev/tpm0
  systemd.tpm2.enable = false;

  nixpkgs.hostPlatform = "aarch64-linux";

  networking.hostName = "dragon";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Lisbon";
  i18n.defaultLocale = "en_US.UTF-8";

  environment.systemPackages = with pkgs; [
    git
    htop
  ];
  system.stateVersion = "26.05";
}
