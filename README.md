# Gruvbox_i3_Dotfiles
Cai dat package 

    sudo pacman -S --needed - < pkglist.txt

Cai dat yay

    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si

Cai dat package aur 

    yay -S --needed - < aurlist.txt

Khoi dong ly display manager

    sudo systemctl enable ly@tty1.service
    sudo systemctl start ly@tty1.service

Set zsh as default

    chsh -s $(which zsh)

Install ohmyzsh

    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    
Zsh Must-Have Plugin

    git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting

Nerd Font

    sudo pacman -S ttf-jetbrains-mono-nerd

Install Powerlevel 10k

    git clone https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k


