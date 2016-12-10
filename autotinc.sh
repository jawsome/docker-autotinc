#!/bin/sh
#
# autotinc - A helper for auto-configuring tinc based on docker container
#
# Information we need:
#   * Subnet: A subnet which this node can route to and show "own" in the tinc network.
#   * Address: This is an entry in the form of either IP address or FQDN that this node is reachable at.
#       For instance, in an AWS environment,
#
#  Server:
#  autotinc.sh start $SUBNET $DNS
#  autotinc.sh start 10.0.0.0/24
#  autotinc.sh start 10.0.0.0/24 dynamic.dns.net
#
#  Client:
#  autotinc.sh
#  autotinc.sh add address somethingsomething.ec2.aws.amazon.com
#  autotinc.sh add subnet 10.1.0.0/24
#    > Adds 10.1.0.0/24 as a subnet owned by this node.
#  autotinc.sh add subnet 10.2.0.0/24 12ced7b65c42
#    > Address 10.2.0.0/24 as a subnet owned by 12ced7b65c42
#  autotinc.sh add node
#    > Imports other nodes
#
#  Living script right now. Do not use.
#

NETWORK=autotinc
TINCNET=172.31.255.$(( ( RANDOM % 250 )  + 1 ))
TINCIFTYPE=tun
TINCDIR=/etc/tinc
TINC="/usr/local/sbin/tinc -n $NETWORK"
IP=$(hostname -i)
NAME=$(hostname -s)

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
