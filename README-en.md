# Nix/NixOS configuration of xieby1

This repository keeps my Nix/NixOS configuration.
It contains a lot of my configuration of various software,
Such as gnome desktop, such as vim and so on.
You can use the configuration of this repository to configure a complete NixOS.
You can also use some of the packages and modules to expand your own Nix/NixOS.
If you want to try NixOS, refer to [Install NixOS](#install-nixos) and [Configure Nix](#configure-nix).
If you just want to try Nix, you can skip [Install NixOS](#install-nixos) and go directly to [Configure Nix](#configure-nix).
If you not only want to install Nix/NixOS, but also want to know more about Nix/NixOS,
welcome to check out the documentation in this repo [xieby1.github.io/nix_config](https://xieby1.github.io/nix_config).

* Use nix expression,not nix flakes
* Use NixOS stable channel (current version 22.05),not unstable channel
* Ubuntu-based usage habits
* Multiplatform
  * NixOS: QEMU✅, NixOS single-boot system✅, NixOS+Windows dual-boot system✅
  * Nix: Linux✅, Android (nix-on-droid)✅, WSL2✅

## Table of contents

<!-- vim-markdown-toc GFM -->

* [Folder structure](#folder-structure)
* [Relationship between Nix and NixOS](#relationship-between-nix-and-nixos)
* [Usage Scenarios](#usage-scenarios)
* [Install NixOS](#install-nixos)
  * [Prepare an image](#prepare-an-image)
  * [Partition](#partition)
  * [File system](#file-system)
  * [Basic configuration](#basic-configuration)
* [Configure Nix](#configure-nix)
  * [Import configuration](#import-configuration)
  * [Config nix channels](#config-nix-channels)
  * [Deploy configuration](#deploy-configuration)
* [Ideas behind my configuration](#ideas-behind-my-configuration)
  * [Gnome desktop](#gnome-desktop)
    * [Wayland or X11](#wayland-or-x11)
    * [New module mime.nix](#new-module-mimenix)
    * [New module gsettings.nix](#new-module-gsettingsnix)
  * [Qv2ray proxy](#qv2ray-proxy)
  * [Text editor](#text-editor)
    * [NeoVim or Vim](#neovim-or-vim)
    * [Typora alternatives (Obsidian or Marktext)](#typora-alternatives-obsidian-or-marktext)
  * [Input method](#input-method)
  * [chroot or docker](#chroot-or-docker)
* [References](#references)

<!-- vim-markdown-toc -->

## Folder structure

* system.nix: system configuration (nixos-rebuild configuration)
  * sys/cli.nix: system CLI configuration
  * sys/gui.nix: system GUI configuration
* nix-on-droid.nix: android configuration (with home-manager configuration)
* home.nix: user configuration (home-manager configuration)
  * usr/cli.nix: user CLI configuration
  * usr/gui.nix: user GUI configuration

## Relationship between Nix and NixOS

Nix is an advanced package management system for managing software packages.
Its target is the same as that of common package managers such as apt and rpm.
Comparing with these package managers, Nix adopts a pure function construction model, uses hashes to store packages and adopts other ideas.
These ideas make it easy for Nix to do reproducible builds and resolve dependency hell.
Nix is born from research conducted during Dolstra's PhD,
which is detailed in his doctor dissertation[^doc_thesis],

NixOS regards the entire Linux operating system (including the kernel) as a collection of software packages and uses Nix to manage it.
In other words, NixOS is a Linux distribution that uses the Nix package manager.

You can use the Nix package manager alone to manage your user programs.
You can also use NixOS to have your entire operating system managed by Nix.
The most intuitive advantage brought by Nix/NixOS is that as long as the Nix/NixOS configuration files are kept,
an identical software environment/OS can be restored.
(Of course this is only ideal.
The impure feature of nix 2.8, home-manager etc. are breaking this.
But don't worry.
As long as the configuration files are kept, an almost identical software environment/OS can be generated on Nix/NixOS)

At this point you may be wondering, Nix/NixOS can manage systems, software and their configuration, but what about data?
Although Nix/NixOS does not directly manage data, Nix/NixOS can manage data synchronization software well.
For example, using the open source software Syncthing, or the open source service NextCloud, or the commercial service Google Drive.
Therefore, as long as you keep the configuration files of Nix/NixOS,
you can easily build a software env/OS that contains the software, configuration, and data you are familiar with.

My Nix/NixOS configuration are hosted here
[github.com/xieby1/nix_config](https://github.com/xieby1/nix_config).

## Usage Scenarios

* OS re-installation: recover the env of old OS
* Dual boot OS: keep WSL and Linux have same env
* Virtual machine: keep local env and VM have same env
* Container: keep local env and container have same env
* Multiple devices: keep multiple computers/phones[^nix-on-droid] have same env

## Install NixOS

The installation refers to the [official installation documentation](https://nixos.org/manual/nixos/stable/#sec-installation).
If you have already installed NixOS, you can skip this step and go directly to Install My Configuration.

### Prepare an image

QEMU:

```bash
# Download minimal ISO image: https://nixos.org/download.html
# Create a qemu hard disk (32GB in size)
qemu-img create -f qcow2 <output/path/to/nix.qcow2> 32G
# Install the ISO image to qemu hard disk
qemu-system-x86_64 -display gtk,window-close=off -vga virtio -device e1000,netdev=net0 -netdev user,id=net0,hostfwd=tcp::5556-:22,smb=/home/xieby1/ -m 4G -smp 3 -enable-kvm -hda </path/to/nix.qcow2> -cdrom </path/to/nixos-minial.iso> -boot d &
```

Physical machine:

```bash
# I haven't explored the method of connecting to wifi from the command line.
# So currently use gnome ISO instead of the minimal ISO.
# Download gnome ISO from: https://nixos.org/download.html
# Make a bootable usb stick
sudo dd if=<path/to/nixos.iso> of=</dev/your_usb>
sync
# Reboot into the usb system
# Noted: You need to cancel the secure boot in the BIOS, in some case the usb cannot boot.
```

### Partition

After entering the ISO system, create the partitions.
3 partitions are needed: a boot partition, an OS partition, a swap partition.
QEMU and single-OS boot need all 3 partitions.
Dual-OS boot needs the latter 2 partitions.

QEMU:

```bash
sudo bash
parted /dev/sda -- mklabel msdos
parted /dev/sda -- mkpart primary 1MiB -8GiB
parted /dev/sda -- mkpart primary linux-swap -8GiB 100%
```

Single boot

```bash
parted /dev/sda -- mklabel gpt
parted /dev/sda -- mkpart primary 512MiB -8GiB
parted /dev/sda -- mkpart primary linux-swap -8GiB 100%
parted /dev/sda -- mkpart ESP fat32 1MiB 512MiB
parted /dev/sda -- set 3 esp on
```

Dual boot

The detailed usage of parted has not yet been explored, and the `disk` software is currently used to visualize the partition process.

* Create an Ext4 partition and name it nixos
* Create Other->swap partition

### File system

```bash
mkfs.ext4 -L nixos /dev/<os partition>
mkswap -L swap /dev/<swap partition>
swapon /dev/<swap partition>
mkfs.fat -F 32 -n boot /dev/<boot partition>      # for single boot
mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot                          # for single boot and dual boot
mount /dev/disk/by-label/boot /mnt/boot     # for single boot and dual boot
```

### Basic configuration

* Generate configuration file
```bash
nixos-generate-config --root /mnt
```
* modify /mnt/etc/nixos/configuration.nix,
  * change `networking.hostName`
  * enable proxy (if you are not bothered by GFW, skip this step)
    * The host machine ip in QEMU is 10.0.2.2
    * During the installation process, you need to use the proxy service of another computer or host
    * After deploying my nixos configuration, the qv2ray service will be avialable
    * `networking.proxy.default = "http://user:password@proxy:port/";`
    * `networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";`
  * (For QEMU and single boot) Uncomment the following to enable grub support
    * `boot.loader.grub.device = "/dev/sda";`
  * (Optional) Remove the firewall so that kdeconnect works
    * `networking.firewall.enable = false;`
  * (dual boot) Automatic detection of operating system startup entries
    * `boot.loader.grub.useOSProber = true;`
  * Add a user
    * `users.users.xieby1`
  * Add softwares
    * `environment.systemPackages = with pkgs; [vim git];`

Finally,

```bash
nixos-install
reboot
```

After rebooting, enter NixOS.

## Configure Nix

Nix installation refers to https://nixos.org/download.html

### Import configuration

Import my configuration into the basic configuration.

```bash
git clone https://github.com/xieby1/nix_config.git ~/.config/nixpkgs
vim /etc/nixos/configuration.nix
# Add the path of system.nix to imports
```

### Config nix channels

Noted: `sudo` may be omitted in Nix.

```bash
# (For users in mainland China) replace with Tsinghua tuna mirror
sudo nix-channel --add https://mirror.tuna.tsinghua.edu.cn/nix-channels/nixos-22.05 nixos # for NixOS
sudo nix-channel --add https://mirror.tuna.tsinghua.edu.cn/nix-channels/nixos-22.05 nixpkgs # for Nix
# Add home manager channel
sudo nix-channel --add https://github.com/nix-community/home-manager/archive/release-22.05.tar.gz home-manager
sudo nix-channel --update
```

### Deploy configuration

```bash
sudo nixos-rebuild switch # Only for NixOS
# Install home-manager
nix-shell '<home-manager>' -A install
home-manager switch
```

## Ideas behind my configuration

### Gnome desktop

#### Wayland or X11

Some of the software I use depends on x11 and cannot run in wayland, so I choose x11.
For example autokey (I am trying to replace autokey with espanso).
Still keep x11 until a suitable replacement is found.

UI, plugins, shortcut keys, etc. affect the intuitive feeling of the desktop system experience.
Configure the gnome desktop system using gui/gnome.nix.
A large number of settings can be viewed/modified through dconf to assist with modification.

#### New module mime.nix

This module is used to configure file types and default open programs.
Type settings and default program settings are implemented through xdg-mime.

#### New module gsettings.nix

This module is used for gsettings configuration.
The existing dconf.settings does not cover all gsettings functions.
For example, the top bar of gnome-termimal needs to be hidden through gsettings.
For details, refers to [this answer](https://askubuntu.com/questions/416556/shouldnt-dconf-editor-and-gsettings-access-the-same-database) which explains the difference between gsettings (schema id) and dconf (schema path).

### Qv2ray proxy

qv2ray has stopped updating and does not adapt well to high-resolution screens.
Possible GUI replacement v2rayA.

qv2ray requires v2ray core.
Through usr/gui.nix: home.file.v2ray_core,
put v2ray core in the default folder of qv2ray.config/qv2ray/,
so that qv2ray can be used out of the box.

### Text editor

#### NeoVim or Vim

The support for NeoVim and Vim in the NixOS community is unequal,
as can be seen from the plugin management.

Configuring the vim plugin requires vim_configurable.customize, which is very complicated.
For details, see nixpkgs git commit: 3feff06b4dee3fd59312204eee0a2af948098376.

NeoVim can use programs.neovim.plugins, so choose NeoVim.

#### Typora alternatives (Obsidian or Marktext)

After [Typora added "anti-user encryption"](https://github.com/NixOS/nixpkgs/issues/138329),
the nixpkgs community stopped supporting typora.

Marktext is slow to update, and plugins are not yet supported.
Every time you close the file, regardless of whether it is edited or not,
you will be prompted to save.

Obsidian experience is not bad!

### Input method

Follow the usage habits of ubuntu, use fcitx.

* Chinese: cloudpinyin (supports fuzzy sounds, automatic online thesaurus)
* Japanese: mozc
* Korean: hangul

### chroot or docker

chroot needs to mount many directories
to make ubuntu work properly.
But NixOS doesn't provide all FHS directories.

So use docker to provide ubuntu command line environment.

## References

[^doc_thesis]: Dolstra, Eelco. “The purely functional software deployment model.” (2006).

[^nix-on-droid]: [github.com/t184256/nix-on-droid](https://github.com/t184256/nix-on-droid) a termux fork, supporting nix
