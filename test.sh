#!/bin/bash


# Interactively
docker run -it --rm  \
 -p 655:655 \
 -v /dev/net/tun:/dev/net/tun \
 --cap-add NET_ADMIN \
 ndru/autotinc

# As a daemon
docker run -d  \
 -p 655:655 \
 -v /dev/net/tun:/dev/net/tun \
 --cap-add NET_ADMIN \
 ndru/autotinc

# Either way, the default is to daemonize as a log tailer. To interface with the tinc instance inside the container, do the following:
#   containerID=#The docker container ID returned by one of the above commands.
docker exec -it $containerID /bin/tinc -n autotinc
