### aliases

() {
	local color="--color=auto"
	alias ls="ls -F $color"
	alias la="ls -F -A $color"
	alias ll="ls -F -l $color"
	alias lx="ls -F -A -l $color"
}

alias less="less -R --tabs=4"
alias grep="grep --color=auto"
alias k9s="LANG=en_US.UTF-8 k9s"


### environment variables

export LANG=ja_JP.UTF-8
export EDITOR=vim
export WORDCHARS="${WORDCHARS//\//}"


### completion

autoload -Uz compinit && compinit -u

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

zstyle ':chpwd:*' recent-dirs-max 40
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

zstyle ':vcs_info:*' enable git
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

__prompt() {

	local vcs_msg="${vcs_info_msg_0_}"
	local content=()

	local dir="${PWD/#"$HOME\/"/~/}"
	local host="${(U)HOST%%.*}"

	content+=$'\n'

	if [ -n "${SSH_CONNECTION}" ]; then
		content+="%F{13}%B%U${host}%u%b%f:"
	fi

	local git_root="$(git rev-parse --show-toplevel 2>/dev/null)"
	if [ -n "${git_root}" ] && [[ "${PWD}" = "${git_root}"/* ]]; then
		local dir_base="${git_root/#"$HOME\/"/~/}"
		local dir_ext="${PWD#"$git_root/"}"
		content+="%F{14}${dir_base} ❭ %F{14}${dir_ext}%f"
	else
		content+="%F{14}${dir}%f"
	fi

	if [ -n "${vcs_msg}" ]; then
		content+=" %F{8}on%f %F{12}${vcs_msg}%f"
	fi
	if [ -n "${__PROMPT_STATUS_EXTRA}" ]; then
		content+="${__PROMPT_STATUS_EXTRA}"
	fi
	content+=$'\n'

	content+="%(?,%F{10},%F{9})❱%f "

	printf "%s" "${content[@]}"
}


### operating system command

__update_term_title() {
	local title
	if [ $# -gt 0 ]; then
		title="$1"
	elif [ -n "$SSH_CONNECTION" ]; then
		title="${(U)HOST%%.*}:$(basename "$PWD")"
	else
		title="$(basename "$PWD")"
	fi
	printf "\033]0;%s\007" "$title"
}

__update_workdir() {
	if [ -z "${SSH_CONNECTION}" ]; then
		printf "\033]7;file://%s/%s\033\\" "${HOST}" "${PWD}"
	fi
}

if [[ "$TERM" =~ "^(kterm|xterm)" ]]; then
	autoload -Uz add-zsh-hook
	add-zsh-hook precmd __update_term_title
	add-zsh-hook chpwd __update_workdir
	__update_term_title ""
	__update_workdir
fi


### fuzzy finder

export FZF_DEFAULT_OPTS="--exact --no-sort --track --cycle --reverse --info=inline-right --no-scrollbar \
--color=dark,gutter:-1,fg+:5:underline,bg+:-1,hl:12,hl+:12:underline,pointer:13:bold,marker:14:dim \
--pointer=❯"

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

__fuzzy() {
	if (fzf --help > /dev/null 2>&1); then
		fzf "$@"
	fi
}

__fuzzy_multi() {
	if (fzf --help > /dev/null 2>&1); then
		fzf -m "$@"
	fi
}

__fuzzy_multi_sorted() {
	if (fzf --help > /dev/null 2>&1); then
		fzf -m --sort "$@"
	fi
}

__fuzzy_history() {
	fc -RI
	__rewrite_buffer "$(history -nr 1 | awk '!a[$0]++' | __fuzzy --query "$LBUFFER")"
}

__fuzzy_find() {
	local find
	if (fd --help > /dev/null 2>&1); then
		find=(fd . -u --type directory --type file)
	else
		find=(find . \( -type d -or -type f \))
	fi
	__append_to_buffer "$("${find[@]}" | __fuzzy_multi_sorted | tr '\n' ' ')"
}

__fuzzy_cd() {
	local d
	if (fd --help > /dev/null 2>&1); then
		d="$(fd . --type directory | __fuzzy)"
	else
		d="$(find . -type d | __fuzzy)"
	fi
	if [ -n "$d" ]; then
		__rewrite_buffer "cd $(printf "%q" "$d")"
		zle accept-line
	fi
}

__fuzzy_git_log() {
	__append_to_buffer "$(git log --oneline --decorate | __fuzzy_multi --preview-window down,border-top --preview "git show --summary --stat {1}" | cut -d " " -f 1)"
}

__fuzzy_ghq_cd() {
	local d
	d="$(ghq list | __fuzzy)"
	if [ -n "$d" ]; then
		d="$(ghq root)/$d"
		__rewrite_buffer "cd $(printf "%q" "$d")"
		zle accept-line
	fi
}

if (fzf --help > /dev/null 2>&1); then
	zle -N __fuzzy_history
	zle -N __fuzzy_find
	zle -N __fuzzy_cd
	zle -N __fuzzy_git_log
	bindkey '^r' __fuzzy_history
	bindkey '^s' __fuzzy_find
	bindkey '^g' __fuzzy_cd
	bindkey '^t' __fuzzy_git_log
	if (ghq --version > /dev/null 2>&1); then
		zle -N __fuzzy_ghq_cd
		bindkey '^p' __fuzzy_ghq_cd
	fi
fi


### site-specific zshrc

() {
	local files=("${ZDOTDIR:-"${HOME}"}/.site.zshrc"(N))
	for f in "${files[@]}"; do
		source "$f"
	done
}
