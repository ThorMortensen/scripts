#!/usr/bin/env bash



### Install powerline

sudo apt install powerline
udo apt install fonts-powerline

mkdir -p ~/.config/powerline
cat <<-'EOF' > ~/.config/powerline/config.json
{
    "ext": {
        "shell": {
            "theme": "default_leftonly"
        }
    }
}
EOF
powerline-daemon --replace




### bashrc settings

######## My stuff ######

export JAVA_HOME=/usr/lib/jvm/java-8-oracle
export PATH=$PATH:~/intelFPGA_pro/17.0/modelsim_ase/bin:~/scripts:/home/thor/.cargo/bin:/usr/local/go/bin
export GOPATH=~/go

. ~/scripts/bashrc_stuff


#### Install Oh my ZSH

sudo apt-get install zsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
chsh -s $(which zsh)
# Log in and out

git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions

# Add to ~/.zshrc before the "source $ZSH/oh-my-zsh.sh" line
source ~/scripts/zshrc_stuff
