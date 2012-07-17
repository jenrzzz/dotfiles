#!/bin/bash
cd "$(dirname "$0")"
git pull
function doIt() {
	rsync --exclude ".git/" --exclude ".DS_Store" --exclude "bootstrap.sh" --exclude "README.md" --exclude "ssh_config" -av . ~
}
function cp_ssh_cfg() {
  cp ssh_config ~/.ssh/config && chmod 0600 ~/.ssh/config
}
function install_vundle() {
  git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle
}
if [ "$1" == "--force" -o "$1" == "-f" ]; then
	doIt
else
	read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [[ ! -d ~/.vim/bundle/vundle ]]; then
      echo "Installing vundle..."
      install_vundle
    fi
		echo "Copying dotfiles..."
    doIt
    echo "Copying ssh config..."
    ([[ -d ~/.ssh ]] && cp_ssh_cfg) || mkdir ~/.ssh && cp_ssh_cfg
	fi
fi
unset doIt
unset cp_ssh_cfg
source ~/.bash_profile