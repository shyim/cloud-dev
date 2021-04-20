# My Cloud Dev Environment

My personal Cloud Development environment for developing Shopware with NoMachine

## Why I develop in the Cloud?

- Your actual PC/Notebook needs nothing really. 
- You can scale easier your server as your notebook hardware when you need more power. 
- Your environment is same between multiple devices
- You just need a Browser / NX Client to develop on any device. No hassle with port stuff, as the server has a public IP. 

## Tested tools so far

Over the years I have tested many ways to do that. Here all my tested tools so far

- Github Code Spaces
  - Limited to their Hardware and pricing
  - Only VSCode
  - Currently only 2 Instances per account
  - No X-Server (No Cypress GUI)
  
- Coder (Selfhosted VSCode in Browser)
  - Own Infrastructure
  - Only VSCode
  - No X-Server (No Cypress GUI)

- Projector (Jetbrain IDE in Browser)
  - Own Infrastructure
  - Only Jetbrain IDE
  - Pretty instable and very laggy in some scenarios. Hopefully an good competitor in future for VSCode in Browser
  - No X-Server (No Cypress GUI)
  
- XServer Forwarding
  - Locally running XServer and forwarding it into the Server
  - It's pretty laggy even with 3ms Ping to external Server
  
- Okteto
  - Service or Own Kubernetes Infrastructure
  - Knowledge of Kubernetes
  - You still need an IDE locally and your Code will be synchronized into the Cloud Container
  - With many Files like Shopware the synchronization take time and slows down quickly working
  - Can run Cypress GUI
  
- Desktop inside Container with VNC, TeamViewer, AnyDesk access
  - Own Infrastructure
  - Freedom of Linux GUI
  - Install that IDE you want with other Desktop tools
  - Works, but not very smooth makes no fun to develop in it
  - Can run Cypress GUI
  
- Desktop with NoMachine inside Container (**this repository**)
  - Own Infrastructure
  - Freedom of Linux GUI
  - Install that IDE you want with other Desktop tools
  - Runs very smooth

This repository contains my NoMachine configuration.

## Requirements

- Server with 16GB Memory
- Docker
- Docker-Compose
- An wildcard Domain
- Reverse Proxy
- [NoMachine Client](https://www.nomachine.com/en) on your PC or buy NoMachine Enterprise Desktop with WebGUI


## Installation

- Copy `.env.dist` to `.env` and change the password
- Start the containers with `docker-compose up -d`
- Install NoMachine Client or buy NoMachine Enterprise Desktop for Web Client
- Connect to NoMachine `<server-ip>:4000` with user `dev` and your given password

### Preinstalled Software

- Nix Package manager
  - Packages can be installed with nix-env -iA nixpkgs.<name> (e.g `nix-env -iA nixpkgs.nano`)
- Shopware-Docker
  - https://github.com/shyim/shopware-docker
- PhpStorm

## How does it work?

We have two docker containers:
  - dini (Docker)
    - Runs an separate Docker to not stop the current container it self and be little bit isolated
  - desktop
    - Runs Mate Desktop with NoMachine at port 4000
    - Has Nix package manager to installing other packages
    - Uses the dini docker
    
I usally use only PhpStorm inside NoMachine and use my normal browser outside. 
To archive this we need on the Host an Reverse Proxy like nginx/traefik which redirects the dini container.

### Network Flow

Your Local Browser -> Nginx/Traefik/Other-Proxy -> DINI Container -> SWDC with the Shop


### Example Nginx Config

Variables:

- `172.18.0.4`: Is the IP of the Docker Container (`docker inspect --format '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' cloud-dev_docker_1`)
- `shy.ovh`: My dev domain replace it with yours
- `/root/.acme.sh/*.shy.ovh/` contains my wildcard letsencrypt certificate for `shy.ovh` domain
- `/etc/nginx/firewall.conf` contains an simple ip allow and deny list. You should always have an IP Whitelist active. When you have an changing IP generate that file often and reload the nginx server

```
server {
  listen 80;
  listen [::]:80;
  server_name *.shy.ovh;

  proxy_buffering off;
  ignore_invalid_headers off;
  client_max_body_size 0;
  gzip on;

  include /etc/nginx/firewall.conf;

  location / {
    proxy_pass http://172.18.0.4:80;
    proxy_http_version 1.1;

    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_redirect http:// $scheme://;

    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto https;

    proxy_set_header Host $http_host;
  }
}

server {
  listen 443 ssl http2;
  listen [::]:443 ssl http2;
  server_name *.shy.ovh;
  proxy_buffering off;
  ssl_certificate /root/.acme.sh/*.shy.ovh/fullchain.cer;
  ssl_certificate_key /root/.acme.sh/*.shy.ovh/*.shy.ovh.key;
  ssl_session_timeout 1d;
  ssl_session_cache shared:SSL:50m;
  ssl_session_tickets off;
  ssl_protocols TLSv1.2;
  ssl_ciphers HIGH:!aNULL:!MD5:!SHA1:!kRSA;
  ssl_prefer_server_ciphers off;
  ignore_invalid_headers off;
  client_max_body_size 0;
  gzip on;

location ~* ^.+\.(?:css|cur|js|jpe?g|gif|ico|png|svg|webp|html)$ {
expires 1y;
        add_header Cache-Control "public";
   proxy_pass http://172.18.0.4:80;
    proxy_http_version 1.1;

    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_redirect http:// $scheme://;

    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto https;

    proxy_set_header Host $http_host;
}


  include /etc/nginx/firewall.conf;

  location / {
    proxy_pass http://172.18.0.4:80;
    proxy_http_version 1.1;

    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_redirect http:// $scheme://;

    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto https;

    proxy_set_header Host $http_host;
  }
}
```


### Example Traefik Labels (recommended)

Variables:
  - `shy.ovh`: Replace it with your Domain
  - The TLS options are using currently Hetzner DNS for getting the SSL Cert. Replace it with your own
  - The middleware is an ipWhitelist

```yaml
http:
  middlewares:
    home-check:
      ipWhiteList:
        sourceRange:
          - "127.0.0.1/32"
```


```yaml
labels:
      - traefik.enable=true
      - traefik.http.routers.http-phpstorm-docker.entrypoints=web
      - traefik.http.routers.http-phpstorm-docker.rule=HostRegexp(`{subdomain:.+}.shy.ovh`)
      - traefik.http.routers.http-phpstorm-docker.middlewares=home-check@file
      - traefik.http.routers.http-phpstorm-docker.priority=1
      - traefik.http.routers.phpstorm-docker.entrypoints=websecure
      - traefik.http.routers.phpstorm-docker.rule=HostRegexp(`{subdomain:.+}.shy.ovh`)
      - traefik.http.routers.phpstorm-docker.tls=true
      - traefik.http.routers.phpstorm-docker.middlewares=home-check@file
      - traefik.http.routers.phpstorm-docker.tls.certresolver=hetzner
      - traefik.http.routers.phpstorm-docker.tls.domains[0].main=shy.ovh
      - traefik.http.routers.phpstorm-docker.tls.domains[0].sans=*.shy.ovh
      - traefik.http.routers.phpstorm-docker.priority=1
```


## First steps

- Open Terminal in System Tools
- Start docker containers `swdc up`
- Modify the swdc configuration `vi .config/swdc/env`
- Change `DEFAULT_DOMAIN` and `DEFAULT_SERVICES_DOMAIN` to your wildcard domain (e.g `shy.ovh`)
- Restart the setup with `swdc up`
- Clone your project into a new folder in `~/Code/` or create a new one with `swdc create-project <name>`
- Restart the setup with `swdc up`
- The pages are available with `<folder-name>.<domain>` (e.g `sw6.shy.ovh`)

For the usage of the Shopware-Docker see in https://github.com/shyim/shopware-docker
