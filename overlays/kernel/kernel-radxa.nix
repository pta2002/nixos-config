{
  fetchFromGitHub,
  buildLinux,
  lib,
  ...
}:
buildLinux rec {
  version = "6.18.2";
  modDirVersion = version;

  src = fetchFromGitHub {
    owner = "radxa";
    repo = "kernel";
    rev = "e98ca3852907cfaa3ad430aa09c355852571b4f6";
    hash = "sha256-PMF9SRB8jly1ef0VZH/2iwOGj0DtsJAkVULa1G7NZRY=";
  };

  # defconfig = "qcom_module_defconfig";

  # ignoreConfigErrors = true; # not necessarily a good idea
  structuredExtraConfig = with lib.kernel; {
    RUST_FW_LOADER_ABSTRACTIONS = yes;
    # These take forever and we won't need them!
    DRM_AMDGPU = no;
    DRM_AMDGPU_CIK = lib.mkForce unset;
    DRM_AMDGPU_SI = lib.mkForce unset;
    DRM_AMDGPU_USERPTR = lib.mkForce unset;
    DRM_AMD_ACP = lib.mkForce unset;
    DRM_AMD_DC_FP = lib.mkForce unset;
    DRM_AMD_DC_SI = lib.mkForce unset;
    DRM_AMD_ISP = lib.mkForce unset;
    DRM_AMD_SECURE_DISPLAY = lib.mkForce unset;
    DRM_NOUVEAU_SVM = lib.mkForce unset;
    HSA_AMD = lib.mkForce unset;
    HSA_AMD_P2P = lib.mkForce unset;
    DRM_NOVA = no;
    DRM_NOUVEAU = no;

    ARCH_QCOM = yes;
    ARM_QCOM_CPUFREQ_NVMEM = yes;
    ARM_QCOM_CPUFREQ_HW = yes;
    PCIE_QCOM = yes;
    PCIE_QCOM_EP = module;
    # QCOM_EBI2 is not set
    QCOM_TZMEM_MODE_SHMBRIDGE = yes;
    QCOM_QSEECOM = yes;
    QCOM_QSEECOM_UEFISECAPP = yes;
    QCOM_COINCELL = module;
    QCOM_FASTRPC = module;
    SERIAL_QCOM_GENI = yes;
    SERIAL_QCOM_GENI_CONSOLE = yes;
    I2C_QCOM_CCI = module;
    I2C_QCOM_GENI = module;
    SPI_QCOM_QSPI = module;
    SPI_QCOM_GENI = module;
    PINCTRL_QCOM_SPMI_PMIC = yes;
    POWER_RESET_QCOM_PON = module;
    BATTERY_QCOM_BATTMGR = module;
    QCOM_TSENS = yes;
    QCOM_SPMI_ADC_TM5 = module;
    QCOM_SPMI_TEMP_ALARM = module;
    QCOM_LMH = module;
    QCOM_WDT = module;
    REGULATOR_QCOM_REFGEN = module;
    REGULATOR_QCOM_RPMH = yes;
    REGULATOR_QCOM_SPMI = yes;
    REGULATOR_QCOM_USB_VBUS = module;
    VIDEO_QCOM_CAMSS = module;
    VIDEO_QCOM_IRIS = module;
    VIDEO_QCOM_VENUS = module;
    BACKLIGHT_QCOM_WLED = module;
    SND_SOC_QCOM = module;
    USB_DWC3_QCOM = module;
    USB_QCOM_EUD = yes;
    TYPEC_QCOM_PMIC = module;
    SCSI_UFS_QCOM = yes;
    LEDS_QCOM_LPG = module;
    QCOM_LLCC = yes;
    # QCOM_LLCC comes after in the menu, so we can't set this to a module yet...
    EDAC_QCOM = module;
    QCOM_BAM_DMA = yes;
    QCOM_GPI_DMA = module;
    QCOM_HIDMA_MGMT = yes;
    QCOM_HIDMA = yes;
    COMMON_CLK_QCOM = yes;
    QCOM_CLK_RPMH = yes;
    QCOM_HFPLL = yes;
    HWSPINLOCK_QCOM = yes;
    QCOM_APCS_IPC = yes;
    QCOM_IPCC = yes;
    ARM_SMMU_QCOM_DEBUG = yes;
    QCOM_IOMMU = yes;
    QCOM_Q6V5_ADSP = module;
    QCOM_Q6V5_MSS = module;
    QCOM_Q6V5_PAS = module;
    QCOM_SYSMON = module;
    QCOM_WCNSS_PIL = module;
    RPMSG_QCOM_GLINK_RPM = yes;
    RPMSG_QCOM_GLINK_SMEM = module;
    RPMSG_QCOM_SMD = yes;
    SOUNDWIRE_QCOM = module;
    QCOM_AOSS_QMP = yes;
    QCOM_COMMAND_DB = yes;
    QCOM_GENI_SE = yes;
    QCOM_PMIC_PDCHARGER_ULOG = module;
    TYPEC = yes;
    QCOM_PMIC_GLINK = yes;
    QCOM_RMTFS_MEM = yes;
    QCOM_RPMH = yes;
    QCOM_SMEM = yes;
    QCOM_SMP2P = yes;
    QCOM_SOCINFO = yes;
    QCOM_STATS = yes;
    QCOM_APR = yes;
    QCOM_ICC_BWMON = yes;
    QCOM_PBS = yes;
    QCOM_CPR = yes;
    QCOM_RPMHPD = yes;
    QCOM_SPMI_VADC = module;
    QCOM_SPMI_ADC5 = module;
    QCOM_PDC = yes;
    QCOM_MPM = yes;
    RESET_QCOM_AOSS = yes;
    RESET_QCOM_PDC = module;
    PHY_QCOM_EDP = yes;
    PHY_QCOM_QMP = yes;
    # PHY_QCOM_QMP_PCIE_8996 is not set
    PHY_QCOM_EUSB2_REPEATER = yes;
    PHY_QCOM_USB_SNPS_FEMTO_V2 = yes;
    QCOM_L2_PMU = yes;
    QCOM_L3_PMU = yes;
    NVMEM_QCOM_QFPROM = yes;
    NVMEM_QCOM_SEC_QFPROM = module;
    SLIM_QCOM_NGD_CTRL = module;
    INTERCONNECT_QCOM = yes;
    INTERCONNECT_QCOM_OSM_L3 = yes;
    INTERCONNECT_QCOM_QCS8300 = yes;
    INTERCONNECT_QCOM_SA8775P = yes;
    INTERCONNECT_QCOM_SC7280 = yes;
    INTERCONNECT_QCOM_SM8550 = yes;
    INTERCONNECT_QCOM_X1E80100 = yes;
    CRYPTO_DEV_QCOM_RNG = module;
  };
}
