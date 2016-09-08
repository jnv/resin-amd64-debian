FROM ubuntu:xenial

LABEL io.resin.architecture="amd64"

ENV LC_ALL C.UTF-8
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -q update \
	&& apt-get -qy install \
		curl \
		debootstrap \
	&& apt-get install -y --no-install-recommends \
		sudo \
		ca-certificates \
	&& rm -rf /var/lib/apt/lists/*

RUN gpg --recv-keys --keyserver pgp.mit.edu 0x9165938D90FDDD2E

COPY . /usr/src/mkimage

WORKDIR /usr/src/mkimage

CMD ./build.sh

COPY 01_nodoc /etc/dpkg/dpkg.cfg.d/
COPY 01_buildconfig /etc/apt/apt.conf.d/

# Install Systemd

ENV container docker

# We never want these to run in a container
RUN systemctl mask \
    dev-hugepages.mount \
    sys-fs-fuse-connections.mount \
    sys-kernel-config.mount \

    display-manager.service \
    getty@.service \
    systemd-logind.service \
    systemd-remount-fs.service \

    getty.target \
    graphical.target  

COPY entry.sh /usr/bin/entry.sh    
COPY launch.service /etc/systemd/system/launch.service

RUN systemctl enable /etc/systemd/system/launch.service

VOLUME ["/sys/fs/cgroup"]
ENTRYPOINT ["/usr/bin/entry.sh"]
