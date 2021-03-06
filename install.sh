#!/bin/bash

cd ${0::-10}

DOT_FOLDER=$PWD
echo "cd $DOT_FOLDER"
cd $DOT_FOLDER

packages_install() {
    echo "Packages install:"
    sudo apt install zsh tmux emacs htop curl git chrome-gnome-shell xclip mosh dtrx\
         aspell-fr aspell-en ttf-mscorefonts-installer gnome-tweaks texlive-full

    echo "Packages install done!"
    echo ""
}

nerd_font_install() {
    current_dir=$PWD
    if [ ! -d $HOME/config ]
       then
           mkdir $HOME/config
    fi
    cd $HOME/config

    if [ ! -d nerd-fonts-2.0.0 ]
    then
        if [ ! -d nerd-fonts-2.0.0.zip ]
           then
               wget https://github.com/ryanoasis/nerd-fonts/archive/v2.0.0.zip
        fi
        unzip v2.0.0.zip
    fi
    cd nerd-fonts-2.0.0
    ./install.sh
    cd $current_dir
}

backup_dotfiles() {
    if [ ! -d $DOT_FOLDER/backup_files ]
    then
        mkdir $DOT_FOLDER/backup_files
    fi

    for file in $@; do
        if [ -e $file ] && [ ! -L $file ]
        then
            mv $file $DOT_FOLDER/backup_files
        fi
    done
}

create_links() {
    for var in $@; do
        if [ ! -e $HOME/$var ]
        then
            ln -s $DOT_FOLDER/$var ./
        fi
    done
}

terminal_config() {
    echo "Terminal config:"
    cd $HOME

    # Switch shell to zsh
    read -r -p "Do you want choose shell? [y/N] " response
    response=${response,,}    # tolower
    if [[ "$response" =~ ^(yes|y)$ ]]
    then
        chsh
    fi

    # Download and install oh-my-zsh and plugin
    echo "oh-my-zsh install"
    if [ ! -d .oh-my-zsh ]
    then
        sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
            ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    fi

    # Download and install powerlevel10k
    echo "Powerlevel10k install"
    if [ ! -d ~/.oh-my-zsh/custom/themes/powerlevel10k ]
    then
        git clone https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k
    fi

    read -r -p "Do you want install Nerd Fonts? [y/N] " response
    response=${response,,}    # tolower
    if [[ "$response" =~ ^(yes|y)$ ]]
    then
        nerd_font_install
    fi

    echo "Create dotfiles backup"

    backup_dotfiles .tmux.conf .zshrc .dircolors .zprofile

    echo "Create simlinks"

    create_links .tmux.conf .zshrc .dircolors

    echo "Set DEFAUL_USER for zsh"

    echo DEFAULT_USER=\"$USER\" > ~/.zprofile

    echo ""
    echo "Terminal config done!"

    echo "Restart session for end chsh set and set FuraCode Nerd Font Regular in
    Monospace Text in Tweaks Fonts."

}

spacemacs_install() {
    cd $HOME
    read -r -p "Do you want install spacemacs (.emacs.d will be delete)? [y/N] " response
    response=${response,,}    # tolower
    if [[ "$response" =~ ^(yes|y)$ ]]
    then
        if [ -d .emacs.d ]
        then
            rm -rf .emacs.d
        fi
        git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d
    fi
    backup_dotfiles .spacemacs
    create_links .spacemacs
}

git_config() {
    cd $HOME
    backup_dotfiles .gitconfig .gitignore_global
    create_links .gitconfig .gitignore_global
}


read -r -p "Do you want install packages? [y/N] " response
response=${response,,}    # tolower
if [[ "$response" =~ ^(yes|y)$ ]]
then
    packages_install
fi

read -r -p "Do you want configure terminal? [y/N] " response
response=${response,,}    # tolower
if [[ "$response" =~ ^(yes|y)$ ]]
then
    terminal_config
fi

read -r -p "Do you want configure spacemacs? [y/N] " response
response=${response,,}    # tolower
if [[ "$response" =~ ^(yes|y)$ ]]
then
    spacemacs_install
fi

read -r -p "Do you want configure git? [y/N] " response
response=${response,,}    # tolower
if [[ "$response" =~ ^(yes|y)$ ]]
then
    git_config
fi




