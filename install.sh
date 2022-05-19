#!/bin/sh

set -ue

HERE="$(cd "$(dirname "$0")"; pwd)"

run() {
	printf "\$ %s\n" "$*"
	"$@"
}

put() {
	local d="$(dirname "$2")"
	if [ "$d" != "$HOME" ]; then
		run mkdir -p "$d"
	fi
	run ln -sf "$HERE/$1" "$2"
}

put "tmux.conf" "$HOME/.tmux.conf"
put "master.vimrc" "$HOME/.vimrc"
put "master.zshrc" "$HOME/.zshrc"

CONF="${XDG_CONFIG_HOME:-$HOME/.config}"
put "master.gitconfig" "$CONF/git/config"
put "master.gitignore" "$CONF/git/ignore"
put "peco.json" "$CONF/peco/config.json"
