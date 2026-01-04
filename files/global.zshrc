## --- aliases ---

alias ls="ls -F --color=auto"
alias la="ls -F -A --color=auto"
alias ll="ls -F -l --color=auto"
alias lx="ls -F -A -l --color=auto"
alias less="less -R --tabs=4"
alias grep="grep --color=auto"
alias k9s="LANG=en_US.UTF-8 k9s"

kctx() {
	local kctx_config="$HOME/.kube/kctx.config"
	local ctx
	ctx="$(KUBECONFIG="$kctx_config" kubectl config get-contexts -o name | fzf)"
	if [ -z "$ctx" ]; then
		echo "No context selected." >&2
		return 1
	fi
	local temp_file="$(mktemp -t kctx.XXXXXXXXXX)"
	printf 'current-context: "%s\n"' "$ctx" > "$temp_file"
	export KUBECONFIG="$temp_file:$kctx_config"
	kubectl config use-context "$ctx"
}


## --- environment variables ---

export LANG="ja_JP.UTF-8"
export EDITOR="vim"
export WORDCHARS="${WORDCHARS//\//}"

path+=("$HOME/.local/bin")


## --- tool config ---

export LS_COLORS='di=01;36:ln=35:so=32:pi=33:ex=01;31:bd=46;34:cd=43;34:su=41;30:'\
'sg=46;30:tw=42;30:ow=43;30'
zstyle ':completion:*' list-colors 'di=01;36' 'ln=35' 'so=32' 'pi=33' 'ex=01;31' \
'bd=46;34' 'cd=43;34' 'su=41;30' 'sg=46;30' 'tw=42;30' 'ow=43;30'

export FZF_DEFAULT_OPTS="--exact --no-sort --track --cycle --reverse --pointer=❯ \
--info=inline-right --no-scrollbar --gutter=' ' \
--color=dark,gutter:-1,fg+:5:underline,bg+:-1,hl:12,hl+:12:underline,\
pointer:13:bold,marker:14:dim"


## --- zsh completion ---

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


## --- zsh history ---

HISTFILE="${XDG_STATE_HOME:-"$HOME/.local/state"}/zsh/history"
mkdir -p "$(dirname "$HISTFILE")"

HISTSIZE=1000000
SAVEHIST=1000000

setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt share_history
setopt autopushd
setopt pushd_ignore_dups

autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs

zstyle ':chpwd:*' recent-dirs-max 40
zstyle ':chpwd:*' recent-dirs-file "${XDG_STATE_HOME:-"$HOME/.local/state"}/zsh/recent-dirs"

bindkey '^r' history-incremental-pattern-search-backward
bindkey '^s' history-incremental-pattern-search-forward


## --- zsh other options ---

setopt print_eight_bit
setopt no_flow_control
setopt long_list_jobs
setopt notify

bindkey -e
bindkey '^f' forward-word
bindkey '^b' backward-word


## --- zsh prompt ---

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


## --- terminal config ---

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


## --- shortcuts ---

__replace_line() {
	BUFFER="$1"
	CURSOR="${#BUFFER}"
	zle redisplay
}

__write_line() {
	BUFFER="${LBUFFER}$1${RBUFFER}"
	CURSOR+="${#1}"
	zle redisplay
}

__fzf_history() {
	fc -RI
	__replace_line "$(
		history -nr 1 |
		awk '!a[$0]++' |
		fzf --scheme=history --query="$LBUFFER"
	)"
}

__fzf_find() {
	local find
	find=(find . \( -name .git -o -name node_modules \) -prune -o ! -path . -print)
	if (fd --help > /dev/null 2>&1); then
		find=(fd . -H -E .git -E node_modules)
	fi
	__write_line "$(
		"${find[@]}" |
		fzf -m --sort --scheme=path |
		tr '\n' ' '
	)"
}

__fzf_cdr() {
	local dest
	dest="$(cdr -l | sed -E 's/^[0-9]+[[:space:]]+//g' | fzf --scheme=path)"
	if [ -n "$dest" ]; then
		__replace_line "cd $dest"
		zle accept-line
	fi
}

__fzf_ghq_cd() {
	local dest
	dest="$(ghq list | fzf --scheme=path)"
	if [ -n "$dest" ]; then
		dest="$(ghq root)/$dest"
		__replace_line "cd $(printf "%q" "$dest")"
		zle accept-line
	fi
}

__fzf_gist_cd() {
	local dest
	dest="$(gist list | fzf --scheme=path --accept-nth 4)"
	if [ -n "$dest" ]; then
		dest="$(gist root)/$dest"
		__replace_line "cd $(printf "%q" "$dest")"
		zle accept-line
	fi
}

__fzf_git_status() {
	__write_line "$(
		git status --short |
		fzf -m |
		cut -c 4- |
		sed -E 's/.*-> //g' |
		tr '\n' ' '
	)"
}

__git_root() {
	local root
	root="$(git rev-parse --show-toplevel)"
	if [ -n "$root" ]; then
		__replace_line "$(printf "cd %q" "$root")"
		zle accept-line
	fi
}

if (fzf --help > /dev/null 2>&1) || true; then
	zle -N __fzf_history
	zle -N __fzf_find
	zle -N __fzf_cdr
	bindkey '^r' __fzf_history
	bindkey '^t' __fzf_find
	bindkey '^s' __fzf_cdr
	if (git --version > /dev/null 2>&1); then
		zle -N __fzf_git_status
		bindkey -r '^g'
		bindkey '^g^s' __fzf_git_status
	fi
	if (ghq --version > /dev/null 2>&1); then
		zle -N __fzf_ghq_cd
		bindkey '^p' __fzf_ghq_cd
	fi
	if (GIST_ROOT="." gist --version > /dev/null 2>&1); then
		zle -N __fzf_gist_cd
		bindkey '^n' __fzf_gist_cd
	fi
fi

if (git --version > /dev/null 2>&1); then
	zle -N __git_root
	bindkey '^g^r' __git_root
fi


## --- local zshrc ---

() {
	local files=("${ZDOTDIR:-"${HOME}"}/.site.zshrc"(N))
	for f in "${files[@]}"; do
		source "$f"
	done
}

## --- compinit ---

ZCOMPDUMP="${XDG_CACHE_HOME:-"$HOME/.cache"}/zsh/zcompdump"
mkdir -p "$(dirname "$ZCOMPDUMP")"
autoload -Uz compinit && compinit -u -w -d "$ZCOMPDUMP"
