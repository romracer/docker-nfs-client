FROM alpine:3.3
MAINTAINER Ryan Schlesinger <ryan@outstand.com>

# USAGE
# $ docker build -t nfs-client .
# $ docker run -it --privileged=true --net=host -v /mnt/nfs-1 -e SERVER=192.168.0.9 -e SHARE=movies nfs-client
#    or detached:
#       $ docker run -itd --privileged=true --net=host -v /mnt/nfs-1 -e SERVER=192.168.0.9 -e SHARE=movies nfs-client
#    or with some more options:
#       $ docker run -itd \
#             --name nfs-vols \
#             --restart=always \
#             --privileged=true \
#             --net=host \
#             -v /:/mnt/host \
#             -e SERVER=192.168.0.9 \
#             -e SHARE=movies \
#             -e MOUNT_OPTIONS="nfsvers=3,ro" \
#             -e FSTYPE=nfs \
#             -e MOUNTPOINT=/mnt/host \
#                nfs-client


# This is the release of https://github.com/hashicorp/docker-base to pull in order
# to provide HashiCorp-built versions of basic utilities like dumb-init and gosu.
ENV DOCKER_BASE_VERSION=0.0.4
ENV DOCKER_BASE_SHA256SUM=5262aa8379782d42f58afbda5af884b323ff0b08a042e7915eb1648891a8da00

# Set up certificates and our base tools.
RUN apk add --no-cache ca-certificates && \
    cd /tmp && \
    wget -O docker-base.zip https://releases.hashicorp.com/docker-base/${DOCKER_BASE_VERSION}/docker-base_${DOCKER_BASE_VERSION}_linux_amd64.zip && \
    echo "${DOCKER_BASE_SHA256SUM}  docker-base.zip" | sha256sum -c && \
    unzip -d / docker-base.zip && \
    rm docker-base.zip

ENV FSTYPE nfs4
ENV MOUNT_OPTIONS nfsvers=4
ENV MOUNTPOINT /mnt/nfs-1

RUN apk update && apk add --update nfs-utils && rm -rf /var/cache/apk/*
RUN rm /sbin/halt /sbin/poweroff /sbin/reboot

ADD entry.sh /usr/local/bin/entry.sh

HEALTHCHECK --interval=1s --timeout=5s \
    CMD mountpoint -q $MOUNTPOINT || exit 1

ENTRYPOINT ["/usr/local/bin/entry.sh"]
