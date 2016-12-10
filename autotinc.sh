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
TINC="/usr/sbin/tinc -n $NETWORK"
IP=$(hostname -i)
NAME=$(hostname -s)

init () {
  echo "info: Initializing tinc for $NAME on $IP routing $SUBNET"
  $TINC init $NAME
  $TINC add Address $IP
  if [ -n "$SUBNET" ]; then
    $TINC add Subnet $SUBNET
  fi
  if [ -n "$DNS" ]; then
    $TINC add Address $DNS
  fi
  tstart
}

checktun () {
  # Verify tun interface is present
  if [ ! -c "/dev/net/$TINCIFTYPE" ]; then
    echo "Error: /dev/net/tun does not exist."
    exit 1
  fi
}

tstart () {
  checktun
  $TINC start
  # TODO Figure out wtf this is here for
  # TODO Check to see if we need to update our own Address (
  ifconfig $NETWORK $TINCNET netmask 255.255.255.0
  echo -e "\n!\n!\n! --- Exporting node information. Copy from after this line --- !\n"
  $TINC export
  echo -e "\n! ---                                                       --- !\n!\n!\n\n"
  $TINC debug 2
  $TINC log
}

case "$1" in                                                     
  "start" )                                                 
    echo "start"                                         
    if [ -n "$2" ];                                         
      then                                               
        SUBNET="$2"                                              
        if [ -n "$3" ];                           
          then                                              
            DNS="$3"                              
          else                            
            init                                         
        fi                                
      else                                
        init                                                     
    fi                                            
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
  ;; 
  "add" )
    if [ -n "$1" ];
      then
        if [ -n "$2" ];
          then
            case "$2" in
              "address" )
                if [ -z "$3" ];
                  then
                    echo "autotinc: Error: no address provided."
                  else
                    echo "! Adding $3 as an address for ${NAME} (this node) ..."
                    $TINC add Address $3
                fi
                ;;
              "node" )
                echo -e "\n! Paste in below the contents of 'export' from the tinc.autotinc> shell of the remote host then hold CTRL and press D or perform your platform equivalent of <Ctrl>+<D>\n!\n"
                read contents
                echo "Input received. Importing node information to tinc."
                echo "$contents" | $TINC import
                ;;
              "subnet" )
                if [ -n "$3" ];
                  # If no subnet provided, ask for one
                  then
                    echo -e "! Please provide the subnet you wish to add in the CIDR format 10.0.0.0/24 \n!\tHere are the subnets we have currently owned by ${NAME}:\n"
                    $TINC get Subnet
                    echo "Your subnet: "
                    read subnet
                    echo -e "! Adding subnet $3 to $NAME..."
                    $TINC add Subnet $subnet
                    # TODO if clean exit give output or error
                  # Otherwise, add it to tinc
                  else
                    if [ -n "$4" ];
                      then
                        echo -e "\n! Adding $3 as a subnet owned by $4. Here are the subnets this node knows about:\n"
                        $TINC dump subnets
                        echo -e "\n! Adding to tinc..."
                        $TINC add ${4}.Subnet $3
                        echo -e "\n! After adding:"
                        $TINC dump subnets
                    fi
                fi
                ;;
            esac
        fi
    fi
  ;;
esac
