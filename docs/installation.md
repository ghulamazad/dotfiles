# Installation

## 1. Virtual machine (recommended first target)

Hyprland needs working GPU acceleration. Use **QEMU/KVM with virt-manager**:
- Firmware: UEFI (OVMF).
- Video: **Virtio**, with **3D acceleration** enabled, and Display: Spice with OpenGL
  (listen type "None"). This is the commonly recommended setup; exact menu names
  vary by virt-manager version.
- 4+ GB RAM, 2+ cores.
- VirtualBox/VMware are reported to be troublesome for Hyprland; not tested here.

If Hyprland shows a black screen or exits immediately, it is almost always the GPU
setup, not these dotfiles. Your host Intel iGPU does not matter inside the VM:
the guest sees a virtual GPU.

## 2. Base system: Arch Linux

Boot the official Arch ISO (UEFI) and install. The ISO ships `archinstall`, a guided
installer: run `archinstall` in the live shell and work through its menu. Menu names
below are from memory and change between versions, so read what your version shows.

- **Profile / desktop:** choose *Minimal*. Do not pick a desktop; the dotfiles provide it.
- **Disk:** a simple layout is fine in the VM (ext4 or Btrfs). On real hardware you can
  choose Btrfs and encryption here; nothing in this repo touches disk layout, LUKS,
  Btrfs/Snapper or the bootloader.
- **Bootloader:** whatever you prefer (your real machine uses Limine; the guided
  installer's choices vary by version).
- **Network:** choose NetworkManager (the Wi-Fi panel and status use `nmcli`).
- **Audio:** PipeWire (the sound panel uses PipeWire).
- **Additional packages:** add `git` and `sudo` (or `base-devel`) so you can clone
  this repo and install packages, and a user with sudo rights.

Or follow the Arch Installation guide by hand. Reboot into the installed system and
log in on a TTY. I could not open the Arch Wiki from my environment, so I did not
check these steps against it. Verify against the wiki before relying on them.

## 2a. Services plain Arch does not enable for you

`install.sh` installs packages and links config. It never enables services. After it
finishes, check and enable what you need:

```sh
sudo systemctl enable --now NetworkManager bluetooth upower
systemctl --user status pipewire wireplumber   # normally socket-activated; confirm
sudo systemctl enable sddm                     # graphical login screen (optional)
```

Only one display manager may be enabled. If you keep logging in on a TTY, skip `sddm`
and run `start-hyprland` (or `Hyprland`) yourself. If `sddm` fails, press Ctrl+Alt+F3,
log in and run `sudo systemctl disable sddm`.

`paru` is not in the official repositories. If you want it, build it by hand from the
AUR and read the PKGBUILD first. It is not needed by this repo.

## 3. Install the dotfiles

```sh
git clone <repo> ~/dotfiles && cd ~/dotfiles
./install.sh --dry-run
./install.sh
```

The installer: checks it is not root and not on an unexpected distro; verifies each
package exists with `pacman -Si`; installs with `sudo pacman -S --needed` (it asks
first unless `--yes`); backs up conflicting files; creates symlinks; validates.
No AUR, no `makepkg`, no disk operations.

## 4. First run order

1. `Hyprland --version` (must support Lua config, 0.55+).
2. Start the session from a TTY with `start-hyprland` (preferred wrapper on recent
   versions) or `Hyprland`. If neither works, read the version's docs.
3. In Ghostty (Super+Return): `nvim --headless "+Lazy! sync" +qa` to fetch Neovim plugins.
4. Open `docs/keybindings.md`.

## 5. Per-machine settings

Copy `hypr/local.lua.example` to `hypr/local.lua` (git-ignored) for monitors,
keyboard layout etc.
