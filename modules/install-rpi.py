#! @python3@/bin/python3 -B

import sys
import argparse
import os
import json
import shutil


def copy_kernel(bootspec):
    kernel_path = bootspec["org.nixos.bootspec.v1"]["kernel"]
    firmware_target = bootspec["com.pta2002.rpi5"]["firmwarePartition"]
    kernel_target = os.path.join(firmware_target, "kernel.img")
    print(f"--> Copying NixOS kernel from {kernel_path} into {kernel_target}")
    shutil.copy2(kernel_path, kernel_target)
    print("    Done!")


def copy_firmware(bootspec):
    firmware_path = bootspec["com.pta2002.rpi5"]["firmwarePath"]
    firmware_target = bootspec["com.pta2002.rpi5"]["firmwarePartition"]
    overlays_path = os.path.join(firmware_path, "overlays")
    overlays_target = os.path.join(firmware_target, "overlays")
    print(f"--> Installing firmware from {firmware_path} into {firmware_target}")
    for file in os.listdir(firmware_path):
        if not os.path.isdir(file):
            file = os.path.join(firmware_path, file)
            print(f"    Copying {file}")
            shutil.copy2(file, firmware_target)
    if not os.path.isdir(overlays_target):
        print(f"    Creating directory {overlays_target}")
        os.mkdir(overlays_target)
    for file in os.listdir(overlays_path):
        if not os.path.isdir(file):
            file = os.path.join(overlays_path, file)
            print(f"    Copying {file}")
            shutil.copy2(file, overlays_target)
    print("    Done!")


def copy_config(bootspec):
    config_path = bootspec["com.pta2002.rpi5"]["configPath"]
    firmware_target = bootspec["com.pta2002.rpi5"]["firmwarePartition"]
    config_target = os.path.join(firmware_target, "config.txt")
    print(f"--> Copying config from {config_path} into {config_target}")
    shutil.copy2(config_path, config_target)
    print("    Done!")


def make_cmdline(bootspec):
    firmware_target = bootspec["com.pta2002.rpi5"]["firmwarePartition"]
    cmdline_target = os.path.join(firmware_target, "cmdline.txt")
    kernel_params = bootspec["org.nixos.bootspec.v1"]["kernelParams"]
    print(f"--> Writing command line into {cmdline_target}")
    with open(cmdline_target, "w") as f:
        f.write(" ".join(kernel_params))
        f.write("\n")
    print("    Done!")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Install raspberry pi bootloader")
    parser.add_argument(
        "default_config", metavar="DEFAULT-CONFIG", help="NixOS system closure"
    )
    args = parser.parse_args()

    bootspec_path = os.path.join(args.default_config, "boot.json")

    print(f"Using bootspec at {bootspec_path}")

    bootspec = json.load(open(bootspec_path, "r"))

    copy_firmware(bootspec)
    copy_kernel(bootspec)
    copy_config(bootspec)
    make_cmdline(bootspec)
