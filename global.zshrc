### aliases

() {
	local color="--color=auto"
	if [[ "$OSTYPE" = "darwin"* ]]; then
		color="-G"
	fi
	alias ls="ls -F $color"
	alias la="ls -F -A $color"
	alias ll="ls -F -l $color"
	alias lx="ls -F -A -l $color"
}

alias less="less -R --tabs=4"
alias grep="grep --color=auto"
alias unzip932="unzip -O cp932"

see() {
	if [ "$#" -eq 0 ]; then
		vim -R -
	else
		vim -R "$@"
	fi
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
		echo "opening workspace '$ws_file'"
		code "$ws_file"
		return
	else
		local gitroot="$(git rev-parse --show-toplevel 2>/dev/null)"
		if [ -n "$gitroot" ]; then
			echo "opening git root '$gitroot'"
			code "$gitroot"
			return
		fi
	fi
	echo "error: cannot find workspace or git root" >&2
	return 1
}


### environment variables

export LANG=ja_JP.UTF-8
export EDITOR=vim
export WORDCHARS="${WORDCHARS//\//}"


### completion

autoload -Uz compinit && compinit

setopt always_last_prompt
setopt auto_menu
setopt auto_param_keys
setopt auto_param_slash
setopt complete_in_word
setopt list_packed
setopt list_types

setopt magic_equal_subst
setopt mark_dirs

zstyle ':completion:*:default' menu select=2
zstyle ':completion:*' verbose yes
zstyle ':completion:*' use-cache true
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([%0-9]#)*=0=01;31'


### ls coloring

export LS_COLORS='di=01;36:ln=35:so=32:pi=33:ex=01;31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
zstyle ':completion:*' list-colors 'di=01;36' 'ln=35' 'so=32' 'pi=33' 'ex=01;31' 'bd=46;34' 'cd=43;34' 'su=41;30' 'sg=46;30' 'tw=42;30' 'ow=43;30'


### command history

HISTFILE="${XDG_STATE_HOME:-"$HOME/.local/state"}/zsh/history"
mkdir -p "$(dirname "$HISTFILE")"

HISTSIZE=1000000
SAVEHIST=1000000

setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt share_history

bindkey '^r' history-incremental-pattern-search-backward
bindkey '^s' history-incremental-pattern-search-forward


### directory history

autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs

setopt autopushd
setopt pushd_ignore_dups

zstyle ':chpwd:*' recent-dirs-max 30
zstyle ':chpwd:*' recent-dirs-file "${XDG_STATE_HOME:-"$HOME/.local/state"}/zsh/recent-dirs"

mkdir -p "${XDG_STATE_HOME:-"$HOME/.local/state"}/zsh"


### other options

setopt print_eight_bit
setopt no_flow_control
setopt long_list_jobs
setopt notify

bindkey -e
bindkey '^f' forward-word
bindkey '^b' backward-word


### VCS

autoload -Uz vcs_info add-zsh-hook
add-zsh-hook precmd vcs_info

zstyle ':vcs_info:*' enable git svn
zstyle ':vcs_info:*' formats '%b'
zstyle ':vcs_info:*' actionformats '%b(%a)'

zstyle ':vcs_info:svn:*' branchformat '%b@r%r'
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr "!"
zstyle ':vcs_info:git:*' unstagedstr "?"
zstyle ':vcs_info:git:*' formats '%b%u%c'
zstyle ':vcs_info:git:*' actionformats '%b%u%c(%a)'


### prompt

setopt prompt_subst
PROMPT='$(__prompt)'

export VIRTUAL_ENV_DISABLE_PROMPT=1

__prompt() {

	local vcs_msg="${vcs_info_msg_0_}"
	local content=()

	local dir="${PWD/#$HOME\//~/}"
	local host="${(U)HOST%%.*}"

	content+=$'\n'

	content+="%F{14}${dir}%f"
	if [ -n "${vcs_msg}" ]; then
		content+=" | %F{10}${vcs_msg}%f"
	fi
	content+=$'\n'

	content+="%F{13}%n%f"
	if [ -n "${SSH_CONNECTION}" ]; then
		content+="@%F{11}%B%U${host}%u%b%f"
	fi
	content+=" %(?,%F{10},%F{9})%(!,#,$)%f "

	printf "%s" "${content[@]}"
}


### terminal title

__update_term_title() {
	local title
	if [ -n "$SSH_CONNECTION" ]; then
		title="${(U)HOST%%.*}:$(basename "$PWD")"
	else
		title="$(basename "$PWD")"
	fi
	printf "\033]0;%s\007" "$title"
}

if [[ "$TERM" =~ "^(kterm|xterm)" ]]; then
	autoload -Uz add-zsh-hook
	add-zsh-hook precmd __update_term_title
fi


### peco

__rewrite_buffer() {
	BUFFER="$1"
	CURSOR="${#BUFFER}"
	zle redisplay
}

__append_to_buffer() {
	local left="${LBUFFER}$1"
	BUFFER="${LBUFFER}$1${RBUFFER}"
	CURSOR="${#left}"
	zle redisplay
}

__peco_history() {
	fc -RI
	__rewrite_buffer "$(history -nr 1 | awk '!a[$0]++' | peco --query "$LBUFFER" --prompt "history>")"
}

__peco_find() {
	local find
	if (fd --help > /dev/null 2>&1); then
		find=(fd . --type directory --type file)
	else
		find=(find . -not -path '*/.*' \( -type d -or -type f \))
	fi
	__append_to_buffer "$("${find[@]}" | peco --prompt "file>" | tr '\n' ' ')"
}

__peco_cd() {
	local d
	d="$(cdr -l | sed -E "s/^[0-9]+ +//g" | peco --prompt "cd>")"
	if [ -n "$d" ]; then
		__rewrite_buffer "cd $d"
	fi
}

__peco_git_log() {
	__append_to_buffer "$(git log --oneline --decorate | peco --prompt "commit>" | cut -d " " -f 1)"
}

if (peco --help > /dev/null 2>&1); then
	zle -N __peco_history
	zle -N __peco_find
	zle -N __peco_cd
	zle -N __peco_git_log
	bindkey '^r' __peco_history
	bindkey '^s' __peco_find
	bindkey '^g' __peco_cd
	bindkey '^t' __peco_git_log
fi


### custom sources

() {
	local files=("$HOME/."*".zshrc"(N))
	for f in "${files[@]}"; do
		source "$f"
	done
}
