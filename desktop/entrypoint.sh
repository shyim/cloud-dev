#!/bin/bash

if [[ ! -e /usr/NX/etc/server.cfg ]]; then
  mv /usr/NX/etc-preinstalled/* /usr/NX/etc/
  chown nx:root /usr/NX/etc
  chown nx:root /usr/NX/etc/sshstatus
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
  sudo -u dev bash -c 'source /home/dev/.nix-profile/etc/profile.d/nix.sh; nix-env -iA nixpkgs.git nixpkgs.docker nixpkgs.docker-compose nixpkgs.jq nixpkgs.dialog nixpkgs.cachix nixpkgs.shopware-cli nixpkgs.openssh nixpkgs wget
  sudo -u dev bash -c 'source /home/dev/.nix-profile/etc/profile.d/nix.sh; cachix use devenv; nix-env -if https://github.com/cachix/devenv/tarball/latest'
fi

if [[ ! -e /home/dev/Apps/ ]]; then
        mkdir -p /home/dev/Apps/shopware-docker
        chown -R dev /home/dev/Apps/

        cd /home/dev/Apps/
        curl https://download-cdn.jetbrains.com/webide/PhpStorm-2024.1.tar.gz -o phpstorm.tar.gz
        tar xf phpstorm.tar.gz
        rm phpstorm.tar.gz
        mv PhpStorm* PhpStorm
        chown -R dev /home/dev/Apps/
fi

if [[ ! -e /home/dev/Code ]]; then
  mkdir /home/dev/Code
fi

chown -R dev /home/dev/.config/bash/
chown -R dev /home/dev/.local/share/applications
chown -R dev /home/dev/.bashrc

/usr/NX/bin/nxserver --install
/usr/NX/bin/nxserver --startup

tail -f /usr/NX/var/log/nxserver.log
