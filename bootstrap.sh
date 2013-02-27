#!/bin/bash
STARTWD="$(dirname "$0")"
cd $STARTWD
STARTWD=`pwd`

echo -n "Updating dotfiles... "
git pull --quiet origin master
echo "done"
declare -a link_files=(.ackrc .aliases .bash_login .bash_profile .bash_prompt .bashrc .brew .exports .functions .gitattributes .gitconfig .gitignore .gvimrc .hgignore .inputrc .screenrc .tmux.conf .vimrc .wgetrc .zlogin .zshrc)

function doIt() {
    touch ~/.hushlogin
    for f in ${link_files[@]}; do
        if [[ -e ~/$f ]]; then
            if [[ -L ~/$f ]]; then
                echo "    $f is already linked... skipping"
            else
                read -p "$f already exists in your home directory. Do you want to remove it, save a copy, or leave it alone? (r/s/l) " -n 1
                echo
                case $REPLY in
                    r)
                        echo "    Removing $f and linking..."
                        rm -f ~/$f
                        ln -s `pwd`/$f ~/$f
                        ;;
                    s)
                        echo "    Saving old $f as $f.old"
                        mv ~/$f ~/$f.old
                        ln -s `pwd`/$f ~/$f
                        ;;
                    l)
                        echo "    Skipping $f."
                        ;;
                esac
            fi
        else
            echo "    $f"
            ln -s `pwd`/$f ~/$f
        fi
    done
    rsync -av ".vim/" ~/.vim/ --quiet
}

function cp_ssh_cfg() {
    cp ssh_config ~/.ssh/config && chmod 0600 ~/.ssh/config
}

function install_vundle() {
    if [[ ! -d ~/.vim/bundle ]]; then
        echo "\nIt looks like vim might not be installed, but we'll dump vundle in ~/.vim/bundle anyways."
        mkdir -p ~/.vim/bundle
    fi
    git clone --quiet https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle
}

if [ "$1" == "--force" -o "$1" == "-f" ]; then
    doIt
else
    read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if [[ ! -d ~/.vim/bundle/vundle ]]; then
          echo -n "Installing vundle... "
          install_vundle
          echo "done"
        else
          echo -n "Updating vundle... "
          cd ~/.vim/bundle/vundle
          git pull --quiet
          echo "done"
        fi
        cd $STARTWD
        echo "Copying dotfiles..."
        doIt
        echo "done."

        read -p "Do you want to copy ssh_config? (y/n) " -n 1
        echo
        if [[ $REPLY =~ [Yy]$ ]]; then
            echo -n "Copying ssh config... "
            ([[ -d ~/.ssh ]] && cp_ssh_cfg) || mkdir ~/.ssh && cp_ssh_cfg
            echo "done."
        fi
    fi
fi
unset doIt
unset cp_ssh_cfg
unset install_vundle
unset STARTWD
source ~/.bash_profile
