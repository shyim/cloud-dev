#!/bin/bash

if [[ ! -e /usr/NX/etc/server.cfg ]]; then
  mv /usr/NX/etc-preinstalled/* /usr/NX/etc/
fi

groupadd -r dev -g 443 \
&& useradd -u 1000 -r -g dev -d /home/dev -s /bin/bash -c "dev" dev \
&& adduser dev sudo \
&& chown -R dev:dev /home/dev \
&& echo dev':'$PASSWORD | chpasswd

if [[ -e /home/dev/.nix-profile/etc/profile.d/nix.sh ]]; then
  source /home/dev/.nix-profile/etc/profile.d/nix.sh
else
  chown -R dev /nix
  sudo -u dev bash -c 'sh <(curl -L https://nixos.org/nix/install) --no-daemon'
  sudo -u dev bash -c 'source /home/dev/.nix-profile/etc/profile.d/nix.sh; nix-env -iA nixpkgs.git nixpkgs.docker-compose nixpkgs.jq nixpkgs.dialog'
fi

if [[ ! -e /home/dev/Apps/ ]]; then
        mkdir -p /home/dev/Apps/shopware-docker
        chown -R dev /home/dev/Apps/
        sudo -u dev bash -c 'source /home/dev/.nix-profile/etc/profile.d/nix.sh;git clone https://github.com/shyim/shopware-docker.git /home/dev/Apps/shopware-docker'

        cd /home/dev/Apps/
        curl https://download-cf.jetbrains.com/webide/PhpStorm-2021.1.1.tar.gz -o phpstorm.tar.gz
        tar xf phpstorm.tar.gz
        rm phpstorm.tar.gz
        mv PhpStorm* PhpStorm
        chown -R dev /home/dev/Apps/
fi

if [[ ! -e /home/dev/Code ]]; then
  mkdir /home/dev/Code
fi

/etc/NX/nxserver --startup
tail -f /usr/NX/var/log/nxserver.log