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

## 2. Base system

Install CachyOS (or Arch). Create your user, enable networking, boot to a TTY or a
display manager session. Disk encryption, Btrfs and the bootloader are your
installer's job; nothing here modifies them.

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
