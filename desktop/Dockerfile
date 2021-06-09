FROM debian:stretch-slim

ENV DOCKER_HOST=tcp://docker:2375 \
    DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install --no-install-recommends -y mate-desktop-environment-core mate-desktop-environment mate-indicator-applet curl xorg vim ca-certificates unzip zip bash-completion vim xterm sudo xz-utils

ENV DOCKERVERSION=20.10.7
RUN curl -fsSLO https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKERVERSION}.tgz && \
    tar xzvf docker-${DOCKERVERSION}.tgz --strip 1 -C /usr/local/bin docker/docker && \
    rm docker-${DOCKERVERSION}.tgz && \
    apt-get clean && \
    apt-get autoclean && \
    curl -fSL "https://download.nomachine.com/download/7.6/Linux/nomachine_7.6.2_4_amd64.deb" -o nomachine.deb && \
#    curl -fSL "https://download.nomachine.com/packages/7.6-PRODUCTION/Linux/nomachine-enterprise-desktop_7.6.2_4_amd64.deb" -o nomachine.deb && \ // Enterprise Version
    dpkg -i nomachine.deb && sed -i "s|#EnableClipboard both|EnableClipboard both |g" /usr/NX/etc/server.cfg && \
    rm nomachine.deb && \
    mv /usr/NX/etc /usr/NX/etc-preinstalled

EXPOSE 4000

ADD entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
