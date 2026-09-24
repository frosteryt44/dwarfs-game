# dwarfs-game

A smart Bash script for Linux gamers to launch compressed Windows (`.exe`) and native Linux games directly from **DwarFS** ISO images. 

It automatically handles read-write layers using **fuse-overlayfs**, sets up isolated Wine prefixes, configures shader caches, and launches Windows games through **umu-launcher** (Proton).

## Features

- **Massive Storage Savings:** Run games directly from highly compressed `.dwarfs` or `.dwarf` images.
- **Write Support on Read-Only Images:** Uses `fuse-overlayfs` to create a virtual, modifiable game folder. Saves, configurations, and mods are stored safely in your home directory, keeping the main game image clean.
- **Proton/Wine Isolation:** Automatically creates a dedicated Wine prefix and DXVK state cache for each Windows game.
- **Robust Cleanup:** Guaranteed unmounting of virtual folders and images upon game exit, even if the game crashes or is interrupted (via `trap` signals).

## Prerequisites

Before using this script, ensure you have the following tools installed on your system:

- **DwarFS:** For mounting compressed game images.
- **fuse-overlayfs:** For creating the copy-on-write virtual layer.
- **umu-launcher:** For running Windows games with Proton.
- **Proton:** A compatibility tool installed via Steam (e.g., `proton-cachyos-slr` or standard Proton/Proton-GE).

## Installation & Usage

1. Clone this repository or download the script:
   ```bash
   git clone https://github.com
   cd dwarfs-game-launcher
   ```

2. Make the script executable:
   ```bash
   chmod +x launch_game.sh
   ```

3. Run a game by providing the path to the DwarFS image and the relative path to the game executable inside it:
   ```bash
   ./launch_game.sh /path/to/game.dwarfs bin/game.exe
   ```

## ⚙️ Configuration

By default, the script looks for Proton at `/usr/share/steam/compatibilitytools.d/proton-cachyos-slr`. 

If your Proton installation is located elsewhere, or you want to use a different version (like Proton-GE), you can easily override it by setting the `PROTONPATH` environment variable before running the script:

```bash
EXPORT PROTONPATH="$HOME/.local/share/Steam/compatibilitytools.d/GE-Proton9-1"
./launch_game.sh /path/to/game.dwarfs bin/game.exe
```

## Directory Structure

The script manages data inside your `$HOME` directory using the following layout:

- `~/Games/<Game-Name>/` — The temporary virtual directory where the game runs (automatically cleaned up after exit).
- `~/.local/share/game_overlays/<Game-Name>/` — Permanent game data storage:
  - `/ro_mount/` — Temporary read-only mount point for the DwarFS image.
  - `/upper/` — **Your saves, configuration files, and mods.**
  - `/pfx/` — Isolated Wine prefix for the game.
  - `/shader_cache/` — DXVK state cache.

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

