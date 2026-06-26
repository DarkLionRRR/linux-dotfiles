#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

C_RESET=$'\e[0m'
C_BOLD=$'\e[1m'
C_BLUE=$'\e[34m'
C_GREEN=$'\e[32m'
C_YELLOW=$'\e[33m'
C_RED=$'\e[31m'

declare -A log_types=(
    [INFO]="$C_BLUE"
    [WARN]="$C_YELLOW"
    [SUCCESS]="$C_GREEN"
    [FINISH]="$C_GREEN"
    [ERROR]="$C_RED"
) 

print_log() {
    printf "%s%s[%s]:%s %s\n" "${log_types[$1]}" "$C_BOLD" "$1" "$C_RESET" "${*:2}"
}

# ==== MAIN SCRIPT ====
echo "---- Starting installation -----"

print_log "INFO" "Checking for pacman..."
if ! command -v pacman >/dev/null 2>&1; then
    print_log "ERROR" "Pacman is not installed. Only Arch Linux systems are supported."
    exit 1
fi

# install packages
print_log "WARN" "Refresh and upgrade packages..."
sudo pacman -Suy --noconfirm

print_log "INFO" "Checking depedencies..."
deps=(
    base-devel git man-db man-pages
    neovim bat fastfetch cargo tmux
    bash-completion starship
)
for pkg in "${deps[@]}"; do
    if ! pacman -Q "$pkg" >/dev/null 2>&1; then
        print_log "WARN" "Installing $pkg..."
        sudo pacman -S --noconfirm "$pkg"
        print_log "SUCCESS" "$pkg installed."
    else
        print_log "SUCCESS" "$pkg is already installed."
    fi
done

print_log "INFO" "Checking paru..."
if ! pacman -Q paru >/dev/null 2>&1; then
    tmp_dir=$(mktemp -d)

    print_log "INFO" "Cloning paru repository"
    rm -rf "$tmp_dir"
    git clone --depth 1 https://aur.archlinux.org/paru.git "$tmp_dir"
    cd "$tmp_dir"

    bat PKGBUILD
    read -r -p "Continue installation? [y/N] " answer
    if [[ ! "$answer" =~ ^[yY]|[yY][eE][sS]$ ]]; then
        print_log "WARN" "paru installation canceled."
        rm -rf $tmp_dir
        exit 0
    fi

    print_log "WARN" "Installing paru..."
    makepkg -si

    rm -rf $tmp_dir
else
    print_log "SUCCESS" "paru is already installed."
fi

# readline
print_log "INFO" "Configuring readline..."
if [[ ! -f "$HOME/.inputrc" ]]; then
    ln -s "$SCRIPT_DIR/readline/inputrc" "$HOME/.inputrc" 
    print_log "SUCCESS" "Readline configuration installed."
else
    print_log "WARN" "$C_BOLD~/.inputrc$C_RESET already exists."
fi

# bash
print_log "INFO" "Configuring bash..."
if [[ ! -f "$HOME/.bashrc" ]]; then
    ln -s "$SCRIPT_DIR/bash/bashrc.bash" "$HOME/.bashrc"
    print_log "SUCCESS" "Bash configuration installed."
else
    print_log "WARN" "$C_BOLD~/.bashrc$C_RESET already exists."
fi

# starship
print_log "INFO" "Configuring starship..."
if [[ ! -f "$HOME/.config/starship.toml" ]]; then
    ln -s "$SCRIPT_DIR/starship/starship.toml" "$HOME/.config/starship.toml"
    print_log "SUCCESS" "Starship configuration installed."
else
    print_log "WARN" "$C_BOLD~/.config/starship.toml$C_RESET already exists."
fi

print_log "FINISH" "Installation completed. Restart your terminal."
