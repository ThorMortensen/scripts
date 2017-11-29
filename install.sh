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


git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
