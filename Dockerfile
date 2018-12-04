FROM debian:9 as git
SHELL ["/bin/bash", "-exo", "pipefail", "-c"]

RUN apt-get update ;\
	DEBIAN_FRONTEND=noninteractive apt-get install --no-install-{recommends,suggests} -y \
		git ca-certificates ;\
	apt-get clean ;\
	rm -vrf /var/lib/apt/lists/*

RUN cd / ;\
	git clone https://github.com/Icinga/deb-icinga2.git ;\
	pushd deb-icinga2 ;\
	git checkout e61d7997217e89698ff02b89b3c3a845b651544a ;\
	rm -rf .git

FROM debian:9
SHELL ["/bin/bash", "-exo", "pipefail", "-c"]

RUN apt-get update ;\
	DEBIAN_FRONTEND=noninteractive apt-get install --no-install-{recommends,suggests} -y \
		bash-completion bison build-essential ccache cmake debhelper default-libmysqlclient-dev dh-systemd flex g++ libboost-dev libboost-program-options-dev libboost-regex-dev libboost-system-dev libboost-test-dev libboost-thread-dev libedit-dev libpq-dev libssl-dev libsystemd-dev libyajl-dev po-debconf ;\
	apt-get clean ;\
	rm -vrf /var/lib/apt/lists/*

RUN update-ccache-symlinks

COPY --from=git /deb-icinga2/stretch/debian /icinga2-debian

CMD cd /icinga2 ;\
	ln -vs /icinga2-debian debian ;\
	PATH="/usr/lib/ccache:$PATH" CCACHE_DIR=/icinga2/.ccache-debian9 dpkg-buildpackage -b -uc -us ;\
	rm debian ;\
	mv ../icinga2*.deb .
