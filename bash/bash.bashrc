# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# BASE BASH CONFIG
HISTTIMEFORMAT="%F %T "
HISTCONTROL=ignoredups:ignorespace
HISTSIZE=10000
HISTFILESIZE=20000

shopt -s histappend checkwinsize

PS1="\[\e[38;5;75;1m\]\u@\h\[\e[0m\] \[\e[38;5;76m\]\w\[\e[0m\] \\$ "

# HELPER FUNCTIONS
available_command() {
	command -v "$1" >/dev/null 2>&1
}

eval_if_exists() {
	local cmd=$1
	shift

	available_command "$cmd" || return

	local output
	output="$("$cmd" "$@")" || return

	eval "$output"
}

# MAIN CONFIG
if available_command nvim; then
	export EDITOR=nvim
	export VISUAL=nvim
fi

if ((SHLVL == 1)) && [[ -z $SSH_CONNECTION ]] && available_command fastfetch; then
	printf "\n"
	fastfetch
	printf "\n"
fi

if available_command eza; then
	alias ls="eza"
	alias ll="eza -l --icons"             # длинный список, как ls -l
	alias la="eza -la --icons"            # список всех файлов, включая скрытые
	alias l="eza -lbF --git --icons"      # показывать в длинном формате с иконками и git-статусом
	alias lt="eza --tree --icons -L 3"    # вывод в виде дерева
	alias lg="eza -l --git --icons"       # длинный список с информацией о git
else
	alias ls="ls --color=auto"
	alias ll="ls -lh"					  # длинный список, как ls -l
	alias la="ls -la"					  # список всех файлов, включая скрытые
	alias l="ls -l"						  # показывать в длинном формате с иконками и git-статусом
fi

if available_command batgrep; then
	alias bgrep="batgrep"
fi

eval_if_exists batman --export-env
eval_if_exists batpipe

if available_command batdiff; then
	export BATDIFF_USE_DELTA=true
	alias diff="batdiff"
fi

if available_command bat; then
	bhelp() {
		if (($# == 0)); then
			printf 'usage: bhelp <command> [args...]\n' >&2
			return 2
		fi

		local cmd=$1
		if [[ $(type -t "$cmd") == builtin || $(type -t "$cmd") == keyword ]]; then
			help "$cmd" 2>&1
		else
			"$@" --help 2>&1
		fi | bat --plain --language=help
	}
fi

if available_command fzf; then
	export FZF_DEFAULT_OPTS=$'--layout=reverse
--border
--cycle
--color=fg:#cdd6f4,bg:#1e1e2e,hl:#f38ba8,fg+:#cdd6f4,bg+:#313244
--color=hl+:#f38ba8,info:#cba6f7,prompt:#cba6f7,pointer:#f5e0dc
--color=marker:#f8ebe8,spinner:#f5e0dc,header:#f38ba8,border:#585b70
--color=gutter:#313244'

	eval "$(fzf --bash)"
fi

fd_completions="${BASH_SOURCE[0]%/*}/bash.fd"
[[ -r $fd_completions ]] && . "$fd_completions"
unset -v fd_completions

refresh_mirrorlist() {
	if ! . /etc/os-release; then
		printf 'error: /etc/os-release not readable\n' >&2
		return 2
	fi

	if [[ "$ID" != 'arch' ]]; then
		printf 'error: refresh_mirrorlist working only on Arch Linux\n' >&2
		return 2
	fi

	if ! command -v reflector >/dev/null 2>&1; then
		printf 'error: reflector is not installed\n' >&2
		return 2
	fi

	sudo reflector						\
		--save /etc/pacman.d/mirrorlist \
		--sort rate						\
		--threads 10					\
		--verbose						\
		--country de					\
		--country pl					\
		--country ru					\
		--latest 20						\
		--protocol https
}

install_pkgs() {
	if ! . /etc/os-release; then
		printf 'error: /etc/os-release not readable\n' >&2
		return 2
	fi

	if [[ "$ID" != 'arch' ]]; then
		printf 'error: install_pkgs working only on Arch Linux\n' >&2
		return 2
	fi

	local pkgs_path="$HOME/linux-dotfiles/packages.txt"
	if [[ -r $pkgs_path ]]; then
		sudo pacman -S $(sed 's/#.*//g' $pkgs_path)
	else
		printf "error: $pkgs_path not found\n" >&2
	fi
}

# CLEAR
unset -f available_command
unset -f eval_if_exists
