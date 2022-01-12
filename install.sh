#!/bin/sh

set -ue

run () {
	printf "\$ %s\n" "$*"
	"$@"
}

here="$(cd "$(dirname "$0")"; pwd)"

run ln -sf "$here/tmux.conf" ~/.tmux.conf
run ln -sf "$here/master.vimrc" ~/.vimrc
run ln -sf "$here/master.zshrc" ~/.zshrc

conf_dir="${XDG_CONFIG_HOME:-$HOME/.config}"
run mkdir -p "$conf_dir/git" && run ln -sf "$here/master.gitconfig" "$conf_dir/git/config"
run mkdir -p "$conf_dir/git" && run ln -sf "$here/master.gitignore" "$conf_dir/git/ignore"
run mkdir -p "$conf_dir/peco" && run ln -sf "$here/peco.json" "$conf_dir/peco/config.json"
