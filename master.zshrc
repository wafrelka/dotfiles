# custom sources

() {
	local custom_files=("$HOME/."*".zshrc"(N))
	for f in "${custom_files[@]}"; do
		source "$f"
	done
}


# aliases

case "$OSTYPE" in
	darwin* )
		alias ls='ls -F -G'
		alias la='ls -F -A -G'
		alias ll='ls -F -l -G'
		alias lx='ls -F -A -l -G'
		;;
	* )
		alias ls='ls -F --color=auto'
		alias la='ls -F -A --color=auto'
		alias ll='ls -F -l --color=auto'
		alias lx='ls -F -A -l --color=auto'
		;;
esac

alias less='less -R --tabs=4'
alias grep='grep --color=auto'
alias unzip932='unzip -O cp932'
alias v='vim -R'
alias p='vim -R -'
alias c='code'

with_poetry() {
	if [ "$#" -eq 0 ]; then
		poetry run python
	elif ([ -f "$1" ] && [ "${1##*.}" = "py" ]) || [ "$1" = "-m" ]; then
		poetry run python3 "$@"
	else
		poetry run "$@"
	fi
}

with_bundle() {
	if [ "$#" -eq 0 ]; then
		bundle exec irb
	elif [ -f "$1" ] && [ "${1##*.}" = "rb" ]; then
		bundle exec ruby "$@"
	else
		bundle exec "$@"
	fi
}

with() {
	if (bundle exec pwd >/dev/null 2>&1); then
		with_bundle "$@"
		return
	fi
	if (poetry run pwd >/dev/null 2>&1); then
		with_poetry "$@"
		return
	fi
	echo "cannot detect environment" >&2
	return 1
}

code-workspace() {
	local dir="$(pwd)"
	local ws_file=""
	while true; do
		local ws_files=("$dir/"*".code-workspace"(.N[1,1]))
		if [ "${#ws_files[@]}" -eq 1 ]; then
			ws_file="${ws_files[1]}"
			break
		fi
		parent="$(dirname "$dir")"
		if [ "$parent" = "$dir" ]; then
			break
		fi
		dir="$parent"
	done
	if [ -n "$ws_file" ]; then
		echo "opening '$ws_file'"
		code "$ws_file"
	fi
}


# environment variables

export LANG=ja_JP.UTF-8
export EDITOR=vim
export WORDCHARS="${WORDCHARS//\//}"


# auto completion

autoload -Uz compinit
compinit

setopt list_packed
setopt auto_param_slash
setopt mark_dirs
setopt list_types
setopt auto_menu
setopt auto_param_keys
setopt magic_equal_subst
setopt complete_in_word
setopt always_last_prompt

zstyle ':completion:*:default' menu select=2
zstyle ':completion:*' verbose yes
zstyle ':completion:*' use-cache true
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([%0-9]#)*=0=01;31'


# ls coloring

export LS_COLORS='di=01;36:ln=35:so=32:pi=33:ex=01;31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
zstyle ':completion:*' list-colors 'di=01;36' 'ln=35' 'so=32' 'pi=33' 'ex=01;31' 'bd=46;34' 'cd=43;34' 'su=41;30' 'sg=46;30' 'tw=42;30' 'ow=43;30'


# command history

HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000

setopt hist_ignore_dups
setopt share_history
setopt hist_ignore_space
setopt hist_reduce_blanks

bindkey '^r' history-incremental-pattern-search-backward
bindkey '^s' history-incremental-pattern-search-forward


# directory history

autoload -U chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs
zstyle ":chpwd:*" recent-dirs-max 30


# other options

setopt autopushd
setopt pushd_ignore_dups
setopt print_eight_bit
setopt no_flow_control
setopt long_list_jobs
setopt notify
setopt prompt_subst
autoload -Uz add-zsh-hook
bindkey -e
bindkey "^f" forward-word
bindkey "^b" backward-word


# VCS

autoload -Uz vcs_info

zstyle ":vcs_info:*" enable git svn
zstyle ':vcs_info:*' formats '%b'
zstyle ':vcs_info:*' actionformats '%b(%a)'

zstyle ':vcs_info:svn:*' branchformat '%b@r%r'
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr "!"
zstyle ':vcs_info:git:*' unstagedstr "?"
zstyle ':vcs_info:git:*' formats '%b%u%c'
zstyle ':vcs_info:git:*' actionformats '%b%u%c(%a)'


# prompt

# black: 0, red: 1, green: 2, yellow: 3
# blue: 4, magenta: 5, cyan: 6, white: 7
# bright: +8

_prompt() {

	local vcs_msg="${vcs_info_msg_0_}"

	local content=()

	content+=""

	content+="%F{14}${PWD/#$HOME\//~/}%f"
	content+="${vcs_msg:+ | }%F{10}${vcs_msg}%f"
	content+=""

	content+="%F{13}%n%f"
	if [ -n "$SSH_CONNECTION" ]; then
		content+="@%F{11}%B%U${(U)HOST%%.*}%u%b%f"
	fi
	content+=" %(?,%F{10},%F{9})%(!,#,$)%f "

	for item in "${content[@]}"; do
		if [ -z "$item" ]; then
			printf "\n"
		else
			printf "%s" "$item"
		fi
	done
}

export VIRTUAL_ENV_DISABLE_PROMPT=1
PROMPT='$(_prompt)'
add-zsh-hook precmd vcs_info

# terminal title

_update_term_title() {
	local title
	if [ -n "$SSH_CONNECTION" ]; then
		title="${(U)HOST%%.*}:$(basename "$PWD")"
	else
		title="$(basename "$PWD")"
	fi
	echo -ne "\033]0;$title\007"
}

if [[ "$TERM" =~ "^(kterm|xterm)" ]]; then
	add-zsh-hook precmd _update_term_title
fi

# peco

_rewrite() {
	BUFFER="$1"
	CURSOR=$#BUFFER
	zle redisplay
}

_append() {
	local left="$LBUFFER$1"
	BUFFER="$LBUFFER$1$RBUFFER"
	CURSOR=$#left
	zle redisplay
}

_peco_history() {
	fc -RI
	_rewrite "$(history -nr 1 | awk '!a[$0]++' | peco --query "$LBUFFER" --prompt "history>")"
}

_peco_find() {
	if (fd --help > /dev/null 2>&1); then
		_append "$(fd . --type directory --type file | peco --prompt "file>" | tr '\n' ' ')"
	else
		_append "$(find . -type d -or -type f | peco --prompt "file>" | tr '\n' ' ')"
	fi
}

_peco_cd() {
	local d="$(cdr -l | sed -E "s/^[0-9]+ +//g" | peco --prompt "cd>")"
	if [ -n "$d" ]; then
		_rewrite "cd $d"
	fi
}

_peco_git_log() {
	_append "$(git log --oneline | peco --prompt "commit>" | cut -d " " -f 1)"
}

if (peco --help > /dev/null 2>&1); then
	zle -N _peco_history
	zle -N _peco_find
	zle -N _peco_cd
	zle -N _peco_git_log
	bindkey '^r' _peco_history
	bindkey '^s' _peco_find
	bindkey '^g' _peco_cd
	bindkey '^t' _peco_git_log
fi
