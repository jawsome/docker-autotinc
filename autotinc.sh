#!/bin/sh
#
# autotinc - A helper for auto-configuring tinc based on docker container
# 
# Information we need:
#   * Network Name - This is used to segregate networks. 
#   * 
#  autotinc.sh $subnet $dnsname $network
#  autotinc.sh 10.0.0.0/24
#  autotinc.sh 10.0.0.0/24 dynamic.dns.net 
#  autotinc.sh 10.0.0.0/24 dynamic.dns.net docknet
#
#


if [ -n "$2" ]; then
  NETWORK=$2;
else
  NETWORK=autotinc;
fi
if [ "$3" ]; then
  ADDRESS=$3;
else
  ADDRESS=$(hostname -i)
fi
if [ "$1" ]; then
  SUBNET=$1
fi

TINCNET=172.31.255.$(( ( RANDOM % 250 )  + 1 ))
TINCIFTYPE=tun
TINCDIR=/etc/tinc
TINC="/usr/local/sbin/tinc -n $NETWORK"
IP=$(hostname -i)
NAME=$(hostname)

init () {
  echo "info: Initializing tinc for $NAME on $IP routing $SUBNET"
  $TINC init $NAME
  $TINC add Address $IP
  if [ ! -n "$SUBNET" ]; then
    $TINC add Subnet $SUBNET
  fi
  tstart
}

checktun () {
  # Verify tun interface is present
  if [ ! -c "/dev/net/$TINCIFTYPE" ]; then
    echo "Error: /dev/net/tun does not exist."
    exit 0
  fi
}

tstart () {
  checktun
  $TINC start
  ifconfig $NETWORK $TINCNET netmask 255.255.255.0
  $TINC export
  $TINC log debug
}

if [ "$(ls -A $TINCDIR)" ];
  then
    if [ -d "${TINCDIR}/${NETWORK}" ];
      then
        tstart
      else
        init
    fi
  else 
    init
fi
