source $HOME/.nix-profile/etc/profile.d/nix.sh
export DOCKER_HOST=tcp://docker:2375
PS1='${debian_chroot:+($debian_chroot)}\[\e[1;31m\]\u\[\e[1;33m\]@\[\e[1;36m\]\h \[\e[1;33m\]\w \[\e[1;35m\]\$ \[\e[0m\]'
alias swdc=$HOME/Apps/shopware-docker/swdc
source /usr/share/bash-completion/bash_completion
source $HOME/.config/bash/docker.sh