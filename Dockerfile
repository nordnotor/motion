FROM ubuntu:18.04

MAINTAINER Vlad Tuznichenko <vlad.tuznichenko@gmail.com>

# Arg
ARG ROOTFS_DIR="./rootfs"

ENV PUID=1000 \
    PGID=1000 \
    MODE="prod" \
    WAIT_FOR=""

ENV VERSION 4.1.1
ENV URL https://github.com/Motion-Project/motion/archive/release-${VERSION}.tar.gz

RUN apt-get upgrade && apt-get update && apt-get install -y  \
    libmysqlclient-dev \
    libjpeg-turbo8-dev \
    build-essential \
    libavdevice-dev \
    libavformat-dev \
    libswscale-dev \
    libavcodec-dev \
    libjpeg-turbo8 \
    libavutil-dev \
    libwebp-dev \
    libjpeg-dev \
    libzip-dev \
    automake \
    autoconf \
    pkgconf \
    libtool \
    ssmtp \
    curl \
    git \
    tar

ADD ${URL} /usr/local/motion/motion.tar.gz

RUN cd /usr/local/motion/ && tar -xvzf motion.tar.gz \
  && cd motion-release-${VERSION}  \
  && autoreconf -fiv \
  && ./configure \
  && make \
  && make install \
  && rm /usr/local/motion/motion.tar.gz

RUN ls -la /usr/local/

# Copy files
COPY ${ROOTFS_DIR}/scripts/command /usr/bin/command
COPY ${ROOTFS_DIR}/scripts/entrypoint.sh /usr/bin/entrypoint

COPY ${ROOTFS_DIR}/motion/conf /usr/local/etc/motion
COPY ${ROOTFS_DIR}/motion/event /usr/local/etc/motion/event
COPY ${ROOTFS_DIR}/motion/conf/camera /usr/local/etc/motion/camera

# Add commands
RUN ln -s /usr/bin/command/wait-for.sh /usr/bin/wait-for

# Permission
RUN chmod -R +x /usr/local/etc/motion/event /usr/bin/command /usr/bin/entrypoint

RUN mkdir -p /etc/motion/ /tmp/motion

WORKDIR /

EXPOSE 8080

ENTRYPOINT ["/usr/bin/entrypoint"]

CMD ["motion", "-n", "-c", "/usr/local/etc/motion/motion.conf"]
