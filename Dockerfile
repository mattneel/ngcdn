FROM phusion/baseimage
MAINTAINER Matt Neel <matt@mrneel.com>

# Added by Mark based on https://github.com/phusion/baseimage-docker/issues/58
ENV DEBIAN_FRONTEND noninteractive

# Added by MH based on https://github.com/shincoder/homestead-docker/issues/5
RUN printf "#!/bin/sh\nexit 0" > /usr/sbin/policy-rc.d && \
	locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
RUN	apt-key update
RUN apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db

# Prevent services from automatically starting after installation
RUN echo exit 101 > /usr/sbin/policy-rc.d && \
	chmod +x /usr/sbin/policy-rc.d

# Setup base system
RUN rm -fr /etc/apt/sources.list && touch /etc/apt/sources.list && \
	add-apt-repository -y "deb http://us.archive.ubuntu.com/ubuntu trusty universe" && \
	add-apt-repository -y "deb http://us.archive.ubuntu.com/ubuntu trusty main restricted universe multiverse" && \
	add-apt-repository -y "deb http://us.archive.ubuntu.com/ubuntu trusty-updates main restricted universe multiverse" && \
	add-apt-repository -y "deb http://us.archive.ubuntu.com/ubuntu trusty-backports main restricted universe multiverse" && \
	add-apt-repository -y "deb http://us.archive.ubuntu.com/ubuntu trusty-security main restricted universe multiverse" && \
	add-apt-repository -y "deb http://ftp.osuosl.org/pub/mariadb/repo/10.0/ubuntu trusty main" && \
	apt-get update && \
	apt-get -y dist-upgrade && \
	apt-get -y install curl git tar gzip python

# Install BTSync
ADD scripts/install-btsync.py /tmp/install-btsync.py
RUN python /tmp/install-btsync.py

# Install BTSync runit service
RUN mkdir /etc/service/btsync
ADD config/btsync.runit.conf /etc/service/btsync/run
RUN chmod +x /etc/service/btsync/run

EXPOSE 8888
CMD ["/sbin/my_init"]

