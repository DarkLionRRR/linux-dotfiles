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

eval "$(starship init bash)"
eval "$(batpipe)"
eval "$(fzf --bash)"

export EDITOR=nvim
export VISUAL=nvim
export MANPAGER='nvim +Man!'
export LS_COLORS="$(vivid generate catppuccin-macchiato)"
export BAT_THEME="Catppuccin Mocha"
export BATDIFF_USE_DELTA=true

export FZF_DEFAULT_OPTS=$'--style=minimal
  --layout=reverse
  --border=rounded
  --height=50%
  --info=inline-right
  --highlight-line
  --color=fg:#cdd6f4,hl:#f38ba8,fg+:#cdd6f4,bg+:#313244
  --color=hl+:#f38ba8,info:#cba6f7,prompt:#cba6f7,pointer:#f5e0dc
  --color=marker:#f8ebe8,spinner:#f5e0dc,header:#f38ba8,border:#585b70
  --color=gutter:#313244'
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range=:500 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --icons=always --tree --color=always {} | head -200'"
export FZF_DEFAULT_COMMAND='fd --hidden --strip-cwd-prefix --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="$FZF_DEFAULT_COMMAND --type=d"

DOTFILES_DIR="$(cd -P "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"

aliases=(common pacman paru bat)
for alias_src in "${aliases[@]}"; do
    source "$DOTFILES_DIR/aliases/$alias_src.bash"
done

if command -v eza >/dev/null 2>&1; then
    source "$DOTFILES_DIR/aliases/eza.bash"
else
    source "$DOTFILES_DIR/aliases/ls.bash"
fi
