{ pkgs, lib, ... }:
let
  inherit (pkgs) applyPatches;

  gitJSON = lib.importJSON ./r36.5.0-gitrepos.json;
  gitRepos = lib.mapAttrs (
    relpath: info:
    let
      gitlabPath = lib.strings.removeSuffix ".git" (
        lib.strings.removePrefix "https://gitlab.com/" info.url
      );
      parts = lib.strings.splitString "/" gitlabPath;
      repo = lib.lists.last parts;
      owner = lib.concatStringsSep "/" (lib.lists.init parts);
    in
    pkgs.fetchFromGitLab {
      inherit owner repo;
      inherit (info) rev hash;
    }
  ) gitJSON;

  kernel = pkgs.linux.override {
    # Needed for Jetson Orin support
    # Can be removed once https://nixpkgs-tracker.ocfox.me/?pr=473038 is integrated.
    structuredExtraConfig = with lib.kernel; {
      ARM64_PMEM = yes;
      # Required for nvfancontrol
      THERMAL_GOV_USER_SPACE = yes;
    };
  };

  bsp =
    pkgs.runCommand "l4t-unpacked"
      {
        src = pkgs.fetchurl {
          url = "https://developer.download.nvidia.com/embedded/L4T/r36_Release_v5.0/release/Jetson_Linux_R36.5.0_aarch64.tbz2";
          hash = "sha256-QU5Y2XrEuE+wLLymIdRlmPC8i4Eba5w613iwTo0yHKc=";
        };
        nativeBuildInputs = [
          pkgs.bzip2
          pkgs.gnutar
        ];
      }
      ''
        bzip2 -d -c $src | tar xf -
        mv Linux_for_Tegra $out
      '';

  mkCopyProjectCommand = project: ''
    mkdir -p "$out/${project.name}"
    cp --no-preserve=all -vr "${project}"/. "$out/${project.name}"
  '';

  l4t-oot-projects = [
    (applyPatches {
      name = "hwpm";
      src = gitRepos.hwpm.overrideAttrs { name = "hwpm"; };
      patches = [
        ./patches/hwpm/0061-tegra-hwpm-Fix-build-for-Linux-v6.13.patch
      ];
    })
    (applyPatches {
      name = "nvidia-oot";
      src = gitRepos.nvidia-oot.overrideAttrs {
        name = "nvidia-oot";
      };
      patches = [
        ./patches/nvidia-oot/0016-tegra-virt-alt-Remove-leading-from-include-path-from.patch
        ./patches/nvidia-oot/0017-conftest-work-around-stringify-issue-with-__assign_s.patch
        ./patches/nvidia-oot/0018-gpio-Use-conftest-to-find-if-struct-gpio_chip-has-of.patch
        ./patches/nvidia-oot/0019-drivers-Fix-gpio_chip-.set-callback-for-v6.17.patch
        ./patches/nvidia-oot/0020-r8126-use-conftest-for-hrtimer_init.patch
        ./patches/nvidia-oot/0021-drivers-Fix-from_timer-for-Linux-v6.16.patch
        ./patches/nvidia-oot/0022-BT-deprecate-support-for-of_gpio-calls.patch
        ./patches/nvidia-oot/0023-misc-bluedroid_pm-Use-wakeup_source_register-unregis.patch
        ./patches/nvidia-oot/0024-misc-bluedroid-remove-duplicate-timer-declaration.patch
        ./patches/nvidia-oot/0025-misc-bluedroid_pm-Fix-optional-GPIOs.patch
        ./patches/nvidia-oot/0026-misc-bluedroid_pm-Verify-wakeup-registration.patch
        ./patches/nvidia-oot/0027-misc-bluedroid_pm-Free-proc-on-failure.patch
        ./patches/nvidia-oot/0028-misc-bluedroid_pm-Ensure-host_wake-is-configured.patch
        ./patches/nvidia-oot/0029-kernel-oot-update-driver-license-to-GPL.patch
        ./patches/nvidia-oot/0030-virt-hvc_sysfs-Fix-build-for-Linux-v6.16.patch
        ./patches/nvidia-oot/0031-platform-tegra-uss-io-proxy-Migrate-to-GPIOD.patch
        ./patches/nvidia-oot/0032-virt-tegra-Fix-build-for-Linux-v6.17.patch
        ./patches/nvidia-oot/0033-drivers-crypto-add-priv-pointer-in-context-struct-to.patch
        ./patches/nvidia-oot/0034-drivers-nvmap-calculate-page-address-explicitly.patch
        ./patches/nvidia-oot/0035-ASoC-tegra-Fix-build-for-Linux-v6.15.patch
        ./patches/nvidia-oot/0036-sound-soc-set-Codec-Stream-Card-name-explicitly.patch
        ./patches/nvidia-oot/0037-crypto-tegra-Remove-an-incorrect-iommu_fwspec_free-c.patch
        ./patches/nvidia-oot/0038-sound-soc-use-reasonable-SND_SOC_DAIFMT_CBx_CFx.patch
        ./patches/nvidia-oot/0039-sound-soc-replace-idle_bias_off-with-idle_bias.patch
        ./patches/nvidia-oot/0040-video-tegra-nvmap-Take-lock-before-reading-dmabuf-s-.patch
        ./patches/nvidia-oot/0041-video-tegra-nvmap-Fix-f_count-for-Linux-v6.13.patch
        ./patches/nvidia-oot/0042-drivers-realtek-bt-replace-set_bit-with-hci_set_quir.patch
        ./patches/nvidia-oot/0043-net-marvell-oak-Fix-build-for-Linux-v6.16.patch
        ./patches/nvidia-oot/0044-drm-tegra-syncpoint-base-support-for-chips-t186.patch
        ./patches/nvidia-oot/0045-drm-tegra-move-disply-related-code-under-CONFIG_DRM_.patch
        ./patches/nvidia-oot/0046-drm-tegra-gem-Open-code-drm_prime_gem_destroy.patch
        ./patches/nvidia-oot/0047-drm-tegra-gem-Don-t-attach-dma-bufs-when-not-needed.patch
        ./patches/nvidia-oot/0048-drm-tegra-Update-to-Linux-v6.8.patch
        ./patches/nvidia-oot/0049-drm-tegra-Update-to-Linux-v6.12.patch
        ./patches/nvidia-oot/0050-drm-tegra-Update-to-Linux-v6.13.patch
        ./patches/nvidia-oot/0051-drm-tegra-Update-to-Linux-v6.14.patch
        ./patches/nvidia-oot/0052-drm-tegra-Update-to-Linux-v6.16-rc1.patch
        ./patches/nvidia-oot/0053-drm-tegra-Fix-build-for-Linux-v6.17.patch
        ./patches/nvidia-oot/0054-net-can-mttcan-Fix-build-for-Linux-v6.16.patch
        ./patches/nvidia-oot/0055-net-can-mttcan-Drop-support-for-legacy-kernels.patch
        ./patches/nvidia-oot/0056-net-can-mttcan-Fix-build-for-Linux-v6.17.patch
        ./patches/nvidia-oot/0057-nvmap-Remove-dma_buf_ops-flag-cache_sgt_mapping.patch
        ./patches/nvidia-oot/0058-drm-tegra-Fix-build-for-Linux-v6.14.patch
        ./patches/nvidia-oot/0059-sound-soc-replace-of_property_read_bool-with-of_prop.patch
        ./patches/nvidia-oot/0060-bluetooth-fix-build-issues-with-Linux-v6.18.patch
      ];
      # GCC 15 defaults to -std=c23, where implicit function declarations no longer
      # cause compilation failures. conftest relies on compilation failures from
      # implicit declarations to detect function availability. Also, C23 makes bool
      # a builtin, conflicting with Linux's manual bool definition. Fix: force gnu11.
      postPatch = ''
        sed -i 's/-Wno-implicit-function-declaration -Wno-strict-prototypes"/-Wno-implicit-function-declaration -Wno-strict-prototypes -std=gnu11"/' scripts/conftest/conftest.sh
      '';
    })
    (applyPatches {
      name = "nvgpu";
      src = gitRepos.nvgpu.overrideAttrs { name = "nvgpu"; };
      patches = [
        ./patches/nvgpu/0062-gpu-nvgpu-correct-parameter-of-macro-MODULE_IMPORT_N.patch
        ./patches/nvgpu/0063-nvgpu-timer-replace-hrtimer_init-with-hrtimer_setup.patch
      ];
    })
    (applyPatches {
      name = "nvdisplay";
      src = gitRepos.nvdisplay.overrideAttrs { name = "nvdisplay"; };
      patches = [
        ./0001-nvidia-drm-Guard-nv_dev-in-nv_drm_suspend_resume.patch
        ./patches/nvdisplay/0002-Update-conftest-and-makefiles-for-OE-builds.patch
        ./patches/nvdisplay/0003-conftest-add-fshort-wchar-to-compilation-commands.patch
        ./patches/nvdisplay/0004-conftest-fix-dma_buf_has_dynamic_attachment-test.patch
        ./patches/nvdisplay/0005-Kbuild-add-EXTRA_CFLAGS-to-ccflags-y-when-necessary.patch
        ./patches/nvdisplay/0006-Kbuild-Fix-quoting-on-NV_VERSION_STRING.patch
        ./patches/nvdisplay/0007-Kbuild-fix-symlink-commands.patch
        ./patches/nvdisplay/0008-conftest-fix-drm_gem_object_vmap_has_map_arg-check.patch
        ./patches/nvdisplay/0009-nvdisplay-kernel-open-correct-parameter-of-macro-MOD.patch
        ./patches/nvdisplay/0010-nvdisplay-timer-replace-hrtimer_init-with-hrtimer_se.patch
        ./patches/nvdisplay/0011-nvdisplay-nvidia-check-importer-operations-directly.patch
        ./patches/nvdisplay/0012-nvdisplay-timer-replace-del_timer_sync-with-timer_de.patch
        ./patches/nvdisplay/0013-nvdisplay-nvidia-drm-fb-add-format-info-parameter-to.patch
        ./patches/nvdisplay/0014-nvdisplay-nvidia-drm-remove-unused-date-member.patch
        ./patches/nvdisplay/0015-nvdisplay-nvidia-drm-add-constify-attribute-for-stru.patch
        ./patches/nvdisplay/0016-libspdm-ecc-replace-akcipher-with-crypto_sig-API.patch
      ];
      postPatch = ''
        # GCC 15 defaults to -std=c23; conftest relies on implicit declaration failures
        # to detect function availability (C23 allows them silently). Also add -funsigned-char
        # to match KBUILD_CFLAGS and avoid false-negative conftest results from
        # -Wincompatible-pointer-types errors in kernel headers like linux/efi.h.
        # (OE4T patch 0003 already adds -fshort-wchar, so we only need these two.)
        sed -i 's/-Wno-implicit-function-declaration -Wno-strict-prototypes"/-Wno-implicit-function-declaration -Wno-strict-prototypes -funsigned-char -std=gnu11"/' kernel-open/conftest.sh

        sed -i '/compile_check_conftest "$CODE" "NV_GET_BACKLIGHT_DEVICE_BY_NAME_PRESENT"/c echo "#undef NV_GET_BACKLIGHT_DEVICE_BY_NAME_PRESENT" | append_conftest "functions"' kernel-open/conftest.sh
      '';
    })
    (applyPatches {
      name = "nvethernetrm";
      src = gitRepos.nvethernetrm.overrideAttrs { name = "nvethernetrm"; };
      # Some directories in the git repo are RO.
      # This works for L4T b/c they use different output directory
      postPatch = ''
        chmod -R u+w osi
      '';
    })
  ];

  l4t-oot-modules-sources = applyPatches {
    name = "l4t-oot-sources";
    src = pkgs.runCommand "l4t-oot-sources-raw" { } (
      # Copy the Makefile
      ''
        mkdir -p "$out"
        cp "${bsp}/source/Makefile" "$out/Makefile"
      ''
      # copy the projects
      + lib.strings.concatMapStringsSep "\n" mkCopyProjectCommand l4t-oot-projects
      # See bspSrc/source/source_sync.sh symlink at end of file
      + ''
        ln -vsrf "$out/nvethernetrm" "$out/nvidia-oot/drivers/net/ethernet/nvidia/nvethernet/nvethernetrm"
      ''
    );
    # Apply OE4T patch 0001 to the assembled source tree (patches top-level Makefile).
    # This replaces Makefile.diff: removes nvidia-headers merged-dir approach,
    # switches to KERNEL_SRC/KBUILD_OUTPUT/KERNEL_PATH variable names, and passes
    # OOTSRC to nvdisplay so it finds nvidia-oot headers/symbols without copying.
    patches = [
      ./patches/0001-Reapply-OE-patches-to-main-Makefile.patch
    ];
  };

  nvidia-oot =
    { kernel, kernelModuleMakeFlags }:
    pkgs.stdenv.mkDerivation {
      name = "l4t-oot-modules";
      src = l4t-oot-modules-sources;

      __structuredAttrs = true;
      strictDeps = true;

      nativeBuildInputs = kernel.moduleBuildDependencies;
      depsBuildBuild = [ pkgs.stdenv.cc ];

      makeFlags = kernel.commonMakeFlags ++ [
        "KERNEL_SRC=${kernel.dev}/lib/modules/${kernel.modDirVersion}/source"
        "KBUILD_OUTPUT=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
        "KERNEL_PATH=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
        "INSTALL_MOD_PATH=${placeholder "out"}"
        # OE4T Makefile passes MODLIB directly to sub-makes (hwpm, nvidia-oot, nvgpu),
        # bypassing the kernel's own MODLIB computation from INSTALL_MOD_PATH.
        # Must set it explicitly so modules_install goes to $out.
        "MODLIB=${placeholder "out"}/lib/modules/${kernel.modDirVersion}"
        "IGNORE_PREEMPT_RT_PRESENCE=1"
      ];

      postInstall = ''
        mkdir -p $dev
        cat **/Module.symvers > $dev/Module.symvers

        mkdir -p $dev/include/nvidia
        cp -r out/nvidia-conftest/nvidia/* $dev/include/nvidia/
      '';

      outputs = [
        "out"
        "dev"
      ];

      # installFlags = [ "INSTALL_MOD_PATH=$(out)" ];
      buildFlags = [ "modules" ];

      installTargets = [ "modules_install" ];
      enableParallelBuilding = true;
    };

  l4t-devicetree-sources = pkgs.runCommand "l4t-devicetree-sources" { } (
    lib.strings.concatStrings (
      [ "mkdir -p $out ; cp ${bsp}/source/Makefile $out/Makefile ;" ]
      ++
        lib.lists.forEach
          [ "hardware/nvidia/t23x/nv-public" "hardware/nvidia/tegra/nv-public" "kernel-devicetree" ]
          (project: ''
            mkdir -p "$out/${project}"
            cp --no-preserve=all -vr "${lib.attrsets.attrByPath [ project ] 0 gitRepos}"/. "$out/${project}"
          '')
    )
  );

in
{
  boot.kernelPackages = lib.mkForce (
    (pkgs.linuxPackagesFor kernel).extend (
      final: prev: {
        devicetree = (pkgs.nvidia-jetpack.kernelPackagesOverlay final prev).devicetree.overrideAttrs {
          src = l4t-devicetree-sources;
        };
        nvidia-oot-modules = final.callPackage nvidia-oot { };
      }
    )
  );
}
