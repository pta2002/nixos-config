#! @python3@/bin/python3 -B
import argparse
import os
import os.path
import sys
import errno
import subprocess
import glob
import datetime
import shutil
import ctypes

libc = ctypes.CDLL("libc.so.6")

extra_config = """
@extraConfig@
"""


def mkdir_p(path):
    try:
        os.makedirs(path)
    except OSError as e:
        if e.errno != errno.EEXIST or not os.path.isdir(path):
            raise


def system_dir(profile, generation):
    if profile:
        return "/nix/var/nix/profiles/system-profiles/%s-%d-link" % (
            profile,
            generation,
        )
    return "/nix/var/nix/profiles/system-%d-link" % (generation)


def copy_if_not_exists(source, dest):
    if not os.path.exists(dest):
        shutil.copyfile(source, dest)


def get_generations(profile=None):
    gen_list = subprocess.check_output(
        [
            "@nix@/bin/nix-env",
            "--list-generations",
            "-p",
            "/nix/var/nix/profiles/%s"
            % ("system-profiles/" + profile if profile else "system"),
            "--option",
            "build-users-group",
            "",
        ],
        universal_newlines=True,
    )
    gen_lines = gen_list.split("\n")
    gen_lines.pop()
    return [(profile, int(line.split()[0])) for line in gen_lines]


def get_profiles():
    if os.path.isdir("/nix/var/nix/profiles/system-profiles/"):
        return [
            x
            for x in os.listdir("/nix/var/nix/profiles/system-profiles/")
            if not x.endswith("-link")
        ]
    return []


def profile_path(profile, generation, name):
    return os.readlink("%s/%s" % (system_dir(profile, generation), name))


def copy_from_profile(profile, generation, name, dry_run=False):
    store_file_path = profile_path(profile, generation, name)
    suffix = os.path.basename(store_file_path)
    store_dir = os.path.basename(os.path.dirname(store_file_path))
    efi_file_path = "/efi/nixos/%s-%s.efi" % (store_dir, suffix)
    if not dry_run:
        copy_if_not_exists(store_file_path, "@efiSysMountPoint@%s" % (efi_file_path))
    return efi_file_path


def describe_generation(generation_dir):
    try:
        with open("%s/nixos-version" % generation_dir) as f:
            nixos_version = f.read()
    except IOError:
        nixos_version = "Unknown"

    kernel_dir = os.path.dirname(os.path.realpath("%s/kernel" % generation_dir))
    module_dir = glob.glob("%s/lib/modules/*" % kernel_dir)[0]
    kernel_version = os.path.basename(module_dir)

    build_time = int(os.path.getctime(generation_dir))
    build_date = datetime.datetime.fromtimestamp(build_time).strftime("%F")

    description = "NixOS {}, Linux Kernel {}, Built on {}".format(
        nixos_version, kernel_version, build_date
    )

    return description


def generation_details(profile, generation):
    kernel = copy_from_profile(profile, generation, "kernel")
    initrd = copy_from_profile(profile, generation, "initrd")
    generation_dir = os.readlink(system_dir(profile, generation))
    kernel_params = "systemConfig=%s init=%s/init " % (generation_dir, generation_dir)
    with open("%s/kernel-params" % (generation_dir)) as params_file:
        kernel_params = kernel_params + params_file.read()
    description = describe_generation(generation_dir)
    return {
        "profile": profile,
        "generation": generation,
        "kernel": kernel,
        "initrd": initrd,
        "kernel_params": kernel_params,
        "description": description,
    }


MENU_ENTRY = """
menuentry "NixOS" {{
    loader {kernel}
    initrd {initrd}
    options "{kernel_params}"
    {submenuentries}
}}
"""

SUBMENUENTRY = """
submenuentry "Generation {generation} {description}" {{
    loader {kernel}
    initrd {initrd}
    options "{kernel_params}"
}}
"""


def write_refind_config(path, default_generation, generations):
    with open(path, "w") as f:
        if "@timeout@" != "":
            f.write("timeout @timeout@")

        rev_generations = sorted(generations, key=lambda x: x[1], reverse=True)
        submenuentries = []
        for generation in rev_generations:
            submenuentries.append(
                SUBMENUENTRY.format(**generation_details(*generation))
            )

        f.write(
            MENU_ENTRY.format(
                **generation_details(*default_generation),
                submenuentries="\n".join(submenuentries)
            )
        )

        f.write(extra_config)


def main():
    parser = argparse.ArgumentParser(
        description="Update NixOS-related systemd-boot files"
    )
    parser.add_argument(
        "default_config",
        metavar="DEFAULT-CONFIG",
        help="The default NixOS config to boot",
    )
    args = parser.parse_args()

    mkdir_p("@efiSysMountPoint@/efi/refind")

    if os.getenv("NIXOS_INSTALL_BOOTLOADER") == "1":
        if "@canTouchEfiVariables@" == "1":
            subprocess.check_call(
                ["@refind@/bin/refind-install"],
                env={
                    "PATH": ":".join(
                        [
                            "@efibootmgr@/bin",
                            "@coreutils@/bin",
                            "@utillinux@/bin",
                            "@gnugrep@/bin",
                            "@gnused@/bin",
                            "@gawk@/bin",
                            "@findutils@/bin",
                        ]
                    )
                },
            )
        else:
            print("DONT KNOW WHAT TO DO")

    if "@extraIcons@" != "":
        icons_dir = "@efiSysMountPoint@/efi/refind/extra-icons"
        if os.path.exists(icons_dir):
            if os.path.exists(icons_dir + "-backup"):
                shutil.rmtree(icons_dir + "-backup")
            os.rename(icons_dir, icons_dir + "-backup")
            print(
                "Notice: Backed up existing extra-icons directory as extra-icons-backup."
            )
        shutil.copytree("@extraIcons@", icons_dir)

    if "@extraThemes@" != "":
        themes_dir = "@efiSysMountPoint@/efi/refind/themes"
        if os.path.exists(themes_dir):
            if os.path.exists(themes_dir + "-backup"):
                shutil.rmtree(themes_dir + "-backup")
            os.rename(themes_dir, themes_dir + "-backup")
            print("Notice: Backed up existing themes directory as themes-backup.")
        shutil.copytree("@extraThemes@", themes_dir)

    generations = get_generations()
    for profile in get_profiles():
        generations += get_generations(profile)
    default_generation = None
    for generation in generations:
        if os.readlink(system_dir(*generation)) == args.default_config:
            default_generation = generation

    write_refind_config(
        "@efiSysMountPoint@/efi/refind/refind.conf", default_generation, generations
    )

    # Since fat32 provides little recovery facilities after a crash,
    # it can leave the system in an unbootable state, when a crash/outage
    # happens shortly after an update. To decrease the likelihood of this
    # event sync the efi filesystem after each update.
    rc = libc.syncfs(os.open("@efiSysMountPoint@", os.O_RDONLY))
    if rc != 0:
        print(
            "could not sync @efiSysMountPoint@: {}".format(os.strerror(rc)),
            file=sys.stderr,
        )


if __name__ == "__main__":
    main()
