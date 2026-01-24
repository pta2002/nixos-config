{ pkgs, lib, ... }:
let
  inherit (pkgs) applyPatches;

  gitJSON = lib.importJSON ./rel-36_eng_2025-12-11-gitrepos.json;
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

  bsp = applyPatches {
    name = "bsp";
    src =
      pkgs.runCommand "l4t-unpacked"
        {
          src = pkgs.fetchurl {
            url = "https://developer.nvidia.com/downloads/embedded/l4t/r36_release_v4.4/release/Jetson_Linux_r36.4.4_aarch64.tbz2";
            hash = "sha256-ps4RwiEAqwl25BmVkYJBfIPWL0JyUBvIcU8uB24BDzs=";
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
    patches = [ ./Makefile.diff ];
    postPatch =
      let
        overlay_mb1bct = pkgs.fetchzip {
          url = "https://developer.nvidia.com/downloads/embedded/L4T/r36_Release_v4.4/overlay_mb1bct_36.4.4.tbz2";
          sha256 = "sha256-QWktb8/cZg9ch7IZ3GRnsLuhU9dD1rYrogBeQvWCg2E=";
        };
      in
      ''
        cp -r ${overlay_mb1bct}/* .
      '';
  };

  mkCopyProjectCommand = project: ''
    mkdir -p "$out/${project.name}"
    cp --no-preserve=all -vr "${project}"/. "$out/${project.name}"
  '';

  l4t-oot-projects = [
    (applyPatches {
      name = "hwpm";
      src = gitRepos.hwpm.overrideAttrs { name = "hwpm"; };
      patches = [
      ];
    })
    (applyPatches {
      name = "nvidia-oot";
      src = gitRepos.nvidia-oot.overrideAttrs {
        name = "nvidia-oot";
      };
      patches = [
        ./0001-conftest-Fix-for-GCC-15-by-using-std-gnu11.patch
      ];
    })
    (gitRepos.nvgpu.overrideAttrs { name = "nvgpu"; })
    (applyPatches {
      name = "nvdisplay";
      src = gitRepos.nvdisplay.overrideAttrs { name = "nvdisplay"; };
      patches = [
        ./0001-nvidia-drm-Guard-nv_dev-in-nv_drm_suspend_resume.patch
        ./0002-ANDURIL-Add-some-missing-BASE_CFLAGS.patch
        ./0003-ANDURIL-Update-drm_gem_object_vmap_has_map_arg-test.patch
        ./0004-ANDURIL-override-KERNEL_SOURCES-and-KERNEL_OUTPUT-if.patch
      ];
      postPatch = ''
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

  l4t-oot-modules-sources = pkgs.runCommand "l4t-oot-sources" { } (
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
        "KERNEL_HEADERS=${kernel.dev}/lib/modules/${kernel.modDirVersion}/source"
        "KERNEL_OUTPUT=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
        "INSTALL_MOD_PATH=${placeholder "out"}"
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
