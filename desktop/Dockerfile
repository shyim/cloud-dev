FROM debian:testing

ENV DOCKER_HOST=tcp://docker:2375 \
    DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install --no-install-recommends -y \
	mate-desktop-environment-core \
	mate-desktop-environment \
	mate-applet-brisk-menu \
	mate-indicator-applet \
	mate-applets \
	gnome-icon-theme \
	curl \
	xorg \
	vim \
	ca-certificates \
	unzip \
	zip \
	bash-completion \
	vim \
	xterm \
	sudo \
	xz-utils \
	locales \
	xdg-utils \
	firefox-esr && \
	apt-get clean && \
    apt-get autoclean

RUN curl -fSL "https://apt.iteas.at/iteas/pool/main/n/nomachine/nomachine_7.9.2_1_amd64.deb" -o nomachine.deb && \
    dpkg -i nomachine.deb && sed -i "s|#EnableClipboard both|EnableClipboard both |g" /usr/NX/etc/server.cfg && \
    rm nomachine.deb && \
    mv /usr/NX/etc /usr/NX/etc-preinstalled

EXPOSE 4000

ADD entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
