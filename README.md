A docker container for auto-configuring a tinc daemon within the container.

###containerized tinc 

 [tinc](https://www.tinc-vpn.org) is A Virtual Private Network (VPN) daemon that uses tunnelling and encryption to create a secure private network between hosts on the Internet. This container initializes tinc with some vague reconfigurable assumptions which allow very quick interconnecting mesh VPN networks to be constructed on effectively ANY platform that supports docker. 

checkout test.sh for running 

Try out the base tinc container we use [ndru/tinc](https://hub.docker.com/r/ndru/tinc/).
