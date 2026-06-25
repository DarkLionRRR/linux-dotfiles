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

# readline
print_log "INFO" "Configuring readline..."
if [[ ! -f "$HOME/.inputrc" ]]; then
    ln -s "$SCRIPT_DIR/readline/inputrc" "$HOME/.inputrc" 
    print_log "SUCCESS" "Readline configuration installed."
else
    print_log "WARN" "$C_BOLD~/.inputrc$C_RESET already exists."
fi

print_log "FINISH" "Installation completed. Restart your terminal."
