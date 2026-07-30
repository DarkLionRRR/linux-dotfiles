#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

C_RESET=$(tput sgr0)
C_BOLD=$(tput bold)
C_BLUE=$(tput setaf 4)
C_GREEN=$(tput setaf 2)
C_YELLOW=$(tput setaf 3)
C_RED=$(tput setaf 1)

declare -A log_types=(
    [INFO]="$C_BLUE"
    [WARN]="$C_YELLOW"
    [SUCCESS]="$C_GREEN"
    [FINISH]="$C_GREEN"
    [ERROR]="$C_RED"
) 

bold() { printf "%s%s%s" "$C_BOLD" "$*" "$C_RESET"; }
print_log() { printf "%s%s %s\n" "${log_types[$1]}" "$(bold "[$1]:")" "${*:2}"; }

echo "---- Starting installation -----"

print_log "INFO" "Checking for pacman..."
if ! command -v pacman >/dev/null 2>&1; then
    print_log "ERROR" "Pacman is not installed. Only Arch Linux systems are supported."
    exit 1
fi

print_log "WARN" "Refresh and upgrade packages..."
sudo pacman -Suy --noconfirm

print_log "INFO" "Checking packages..."
pkgs=(
    base-devel diffutils git man-db
    man-pages neovim bat fastfetch
    cargo tmux bash-completion starship
    vivid fd ripgrep git-delta bat-extras
    fzf eza zoxide lua-language-server
)
missing_pkgs=()
for pkg in "${pkgs[@]}"; do
    if ! pacman -Q "$pkg" >/dev/null 2>&1; then
        missing_pkgs+=("$pkg")
        print_log "WARN" "$pkg is missing."
    else
        print_log "SUCCESS" "$pkg found."
    fi
done
if ((${#missing_pkgs[@]})); then
    print_log "INFO" "Installing missing packages..."
    sudo pacman -S --noconfirm "${missing_pkgs[@]}"
    print_log "SUCCESS" "All missing packages installed."
else
    print_log "SUCCESS" "All packages are already installed."
fi

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

declare -A configs=(
    [".gitconfig"]="git/gitconfig"
    [".inputrc"]="readline/inputrc"
    [".bashrc"]="bash/bashrc.bash"
    [".config/tmux"]="tmux/"
    [".ripgreprc"]="ripgrep/ripgreprc"
    [".config/fastfetch"]="fastfetch/"
    [".config/starship.toml"]="starship/starship.toml"
    [".config/nvim"]="nvim/"
)
for config in "${!configs[@]}"; do
    print_log "INFO" "Configuring $(bold "~/$config")..."
    if [[ ! -e "$HOME/$config" ]]; then
        mkdir -p "$(dirname "$HOME/$config")"
        ln -s "$SCRIPT_DIR/${configs[$config]}" "$HOME/$config"
        print_log "SUCCESS" "Configuration installed."
    else
        print_log "WARN" "$(bold "~/$config") already exists."
    fi
done

# config pacman
print_log "INFO" "Configuring $(bold "/etc/pacman.conf")..."
sudo ln -sf "$SCRIPT_DIR/pacman/pacman.conf" "/etc/pacman.conf"
print_log "SUCCESS" "Configuration installed."

# create .env
if [[ ! -f "$SCRIPT_DIR/.env" ]]; then
    cp "$SCRIPT_DIR/.env.example" "$SCRIPT_DIR/.env"
    print_log "SUCCESS" "Created $(bold ".env") using $(bold .env.example)"
fi

mkdir -pv "$HOME/.local/bin"

print_log "FINISH" "Installation completed. Restart your terminal."
