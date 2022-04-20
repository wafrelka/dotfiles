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
alias gxx='g++ --std=c++11 -O2 -Wall -Wextra -Wshadow -Wno-unused-result -fsanitize=undefined,address -DWAFDAYO'
alias be='bundle exec'
alias ber='bundle exec ruby'
alias sourcezshrc='source ~/.zshrc'
alias unzip932='unzip -O cp932'
alias pview='view -'

wscode() {
    local target_dir="${1:-.}"
    local git_root="$(cd "$target_dir" && git rev-parse --show-toplevel)"
    local ws_paths=("$git_root/"*".code-workspace"(N))
    if [ 0 -eq "${#ws_paths[@]}" ]; then
        printf "cannot find '*.code-workspace' in '%s'\n" "$git_root"
        return 1
    fi
    local ws_path="${ws_paths[1]}"
    printf "opening '%s'\n" "$ws_path"
    code "$ws_path"
}


# environment variables

export LANG=ja_JP.UTF-8
export EDITOR=vim
export WORDCHARS="$(echo "$WORDCHARS" | sed s:/::g)"


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
zstyle ':completion:*' completer _expand_alias _expand _complete _ignored
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
bindkey ";2C" forward-word
bindkey ";2D" backward-word


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

	vcs_info

	vcs_msg="${vcs_info_msg_0_}"
	ssh_conn="${SSH_CONNECTION}"

	echo -n "\n"
	echo -n "%F{14}${PWD/#"$HOME\/"/"~/"}%f"
	echo -n "${vcs_msg:+ | }%F{10}${vcs_msg}%f"
	echo -n "\n"
	echo -n "%F{13}%n%f"
	if [ "" != "$ssh_conn" ]; then
		echo -n "@%F{11}%B%U${(U)HOST%%.*}%u%b%f"
	fi
	echo -n " %(?,%F{10},%F{9})%(!,#,$)%f "
}

_rprompt() {

	py_msg=""

	if [[ -n "$VIRTUAL_ENV" ]]; then
		py_msg="+Py"
	fi

	echo -n "%F{11}${py_msg}%f"

}

export VIRTUAL_ENV_DISABLE_PROMPT=1
PROMPT='$(_prompt)'
RPROMPT='$(_rprompt)'

# terminal title

case "${TERM}" in
kterm*|xterm*)
    if [ -n "${KITTY_WINDOW_IDS:-}" ]; then
        _update_term_title() {
            echo -ne "\033]0;${USER}@${HOST%%.*}:${PWD}\007"
        }
    else
        _update_term_title() {
            echo -ne "\033]0;$(basename $PWD)\007"
        }
    fi
    add-zsh-hook precmd _update_term_title
esac

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
	d="$(cdr -l | sed -E "s/^[0-9]+ +//g" | peco --prompt "cd>")"
	if [ "$d" != "" ]; then
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


# custom sources

() {
	local custom_files=("$HOME/."*".zshrc"(N))
	for f in "${custom_files[@]}"; do
		source "$f"
	done
}
