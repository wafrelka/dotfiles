#!/bin/sh

set -ue

run () {
	echo "\$ $@"
	"$@"
}

here="$(cd $(dirname "$0"); pwd)"

run ln -sf "$here/tmux.conf.txt" ~/.tmux.conf
run ln -sf "$here/vimrc.txt" ~/.vimrc
run ln -sf "$here/zshrc.txt" ~/.zshrc

conf_dir="${XDG_CONFIG_HOME:-$HOME/.config}"
run mkdir -p "$conf_dir/git" && run ln -sf "$(pwd)/gitconfig.txt" "$conf_dir/git/config"
run mkdir -p "$conf_dir/git" && run ln -sf "$(pwd)/gitignore.txt" "$conf_dir/git/ignore"
run mkdir -p "$conf_dir/peco" && run ln -sf "$(pwd)/peco.json" "$conf_dir/peco/config.json"
