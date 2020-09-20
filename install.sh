#!/bin/sh

ln -sf "$(pwd)/tmux.conf.txt" ~/.tmux.conf
ln -sf "$(pwd)/vimrc.txt" ~/.vimrc
ln -sf "$(pwd)/zshrc.txt" ~/.zshrc
ln -sf "$(pwd)/gitconfig.txt" ~/.gitconfig

mkdir -p ~/.peco
ln -sf "$(pwd)/peco.json" ~/.peco/config.json
