# azad-dotfiles

A minimal Arch Linux developer desktop. Hyprland, Dark Petrol Lagoon palette and VictorMono Nerd Font everywhere.

## Install

Fresh Arch install, as your normal user, from inside this repo:

```sh
scripts/install-packages.sh      # official repos only; asks before running sudo pacman
scripts/install-config.sh        # copies config into ~; no sudo, no backups
```

Add `--dry-run` to either script to preview, `--yes` to skip its own prompts.
The config installer asks before overwriting a file that differs from the repo.
`scripts/uninstall.sh` removes the copies it made, unless you edited them since.

Then log in (SDDM, or `start-hyprland` from a TTY) and check:

```sh
hyprctl configerrors
```