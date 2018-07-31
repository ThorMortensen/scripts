


alias +install_deb='sudo dpkg -i'
alias +goto_newest_folder='cd $(ls -td -- */ | head -n 1)'

# PATH=$PATH:~/peta_linux/tools/common/petalinux/bin
alias petalinux_init='PATH=$PATH:~/peta_linux/tools/common/petalinux/bin && . ~/peta_linux/settings.sh'