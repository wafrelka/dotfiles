#!/bin/sh

ln -sf "$(pwd)/tmux.conf.txt" ~/.tmux.conf
ln -sf "$(pwd)/vimrc.txt" ~/.vimrc
ln -sf "$(pwd)/zshrc.txt" ~/.zshrc

conf_dir="${XDG_CONFIG_HOME:-$HOME/.config}"
mkdir -p "$conf_dir/git" && ln -sf "$(pwd)/gitconfig.txt" "$conf_dir/git/config"
mkdir -p "$conf_dir/git" && ln -sf "$(pwd)/gitignore.txt" "$conf_dir/git/ignore"
mkdir -p "$conf_dir/peco" && ln -sf "$(pwd)/peco.json" "$conf_dir/peco/config.json"
