# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# always start with tmux
if [[ -z "$TMUX" ]]; then
  exec tmux new-session -A -s main
fi

# ==== SHELL OPTS ====
opts=(globstar extglob checkwinsize histappend autocd cdspell)
shopt -s "${opts[@]}"

# ==== BASE CONFIG ====
HISTSIZE=50000
HISTFILESIZE=100000
HISTCONTROL=ignoredups:erasedups
HISTTIMEFORMAT='%F %T '
PROMPT_COMMAND='history -a; history -c; history -r'

export EDITOR=nvim
export VISUAL=nvim
export MANPAGER='nvim +Man!'

DOTFILES_DIR="$(cd -P "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"

aliases=(common pacman paru ls bat)
for alias_src in "${aliases[@]}"; do
    source "$DOTFILES_DIR/aliases/$alias_src.bash"
done
