# Copyright (C) 2026 memerks <frosteryt44@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://gnu.org>.

#!/bin/bash

PROTONPATH="${PROTONPATH:-/usr/share/steam/compatibilitytools.d/proton-cachyos-slr}"

show_usage() {
    echo "Usage: $(basename "$0") <path/to/dwarfs_image> <executable_relative_path>"
    echo "Example: $(basename "$0") /path/to/game.dwarfs bin/game.exe"
}

if [ "$#" -ne 2 ]; then
    echo "Error: Invalid number of arguments."
    show_usage
    exit 1
fi

IMAGE="$1"
GAME_EXE="$2"

GAME_NAME=$(basename "$IMAGE")
GAME_NAME="${GAME_NAME%.dwarfs}"
GAME_NAME="${GAME_NAME%.dwarf}"

MERGED_DIR="$HOME/Games/$GAME_NAME"
DATA_DIR="$HOME/.local/share/game_overlays/$GAME_NAME"
LOWER_DIR="$DATA_DIR/ro_mount"
UPPER_DIR="$DATA_DIR/upper"
WORK_DIR="$DATA_DIR/work"

cleanup() {
    echo "Cleaning up mounts and folders..."
    cd ~ 2>/dev/null || true

    if mountpoint -q "$MERGED_DIR" 2>/dev/null; then
        fusermount3 -u "$MERGED_DIR" || umount -l "$MERGED_DIR"
    fi

    if mountpoint -q "$LOWER_DIR" 2>/dev/null; then
        fusermount3 -u "$LOWER_DIR" || umount -l "$LOWER_DIR"
    fi

    if [ -d "$MERGED_DIR" ]; then
        rmdir "$MERGED_DIR" 2>/dev/null
    fi
    echo "Finished."
}

trap cleanup EXIT INT TERM

mkdir -p "$LOWER_DIR" "$UPPER_DIR" "$WORK_DIR" "$MERGED_DIR"

if ! mountpoint -q "$LOWER_DIR"; then
    echo "Opening compressed game folder..."
    dwarfs "$IMAGE" "$LOWER_DIR" || exit 1
    sleep 0.5
fi

if ! mountpoint -q "$MERGED_DIR"; then
    echo "Creating virtual folder ~/Games/$GAME_NAME..."
    fuse-overlayfs -o lowerdir="$LOWER_DIR",upperdir="$UPPER_DIR",workdir="$WORK_DIR" "$MERGED_DIR" || exit 1
    sleep 0.5
fi

cd "$MERGED_DIR" || exit 1

EXTENSION="${GAME_EXE##*.}"
EXTENSION=$(echo "$EXTENSION" | tr '[:upper:]' '[:lower:]')

if [ "$EXTENSION" = "exe" ]; then
    echo "Starting .exe game with Proton via umu-launcher..."
    export WINEPREFIX="$DATA_DIR/pfx"
    mkdir -p "$WINEPREFIX"
    mkdir -p "$DATA_DIR/shader_cache"

    export DXVK_STATE_CACHE_PATH="$DATA_DIR/shader_cache"
    export NTSYNC_DISABLE=1
    export PROTONPATH="$PROTONPATH"
    export STEAM_COMPAT_MOUNTS="$MERGED_DIR"
    export GAMEID="umu-$GAME_NAME"

    umu-run "./$GAME_EXE"
else
    echo "Starting Linux native game..."
    chmod +x "./$GAME_EXE"
    "./$GAME_EXE"
fi

echo "Game instance closed."
