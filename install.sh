#!/bin/sh

set -ue

run () {
	echo "\$ $@"
	"$@"
}

run ln -sf "$(pwd)/tmux.conf.txt" ~/.tmux.conf
run ln -sf "$(pwd)/vimrc.txt" ~/.vimrc
run ln -sf "$(pwd)/zshrc.txt" ~/.zshrc

conf_dir="${XDG_CONFIG_HOME:-$HOME/.config}"
run mkdir -p "$conf_dir/git" && run ln -sf "$(pwd)/gitconfig.txt" "$conf_dir/git/config"
run mkdir -p "$conf_dir/git" && run ln -sf "$(pwd)/gitignore.txt" "$conf_dir/git/ignore"
run mkdir -p "$conf_dir/peco" && run ln -sf "$(pwd)/peco.json" "$conf_dir/peco/config.json"
