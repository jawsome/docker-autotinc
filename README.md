> A docker container for auto-configuring a tinc daemon within the container.

## containerized tinc 


 [tinc](https://www.tinc-vpn.org) is A Virtual Private Network (VPN) daemon that uses tunnelling and encryption to create a secure private network between hosts on the Internet. This container initializes tinc with some vague reconfigurable assumptions which allow very quick interconnecting mesh VPN networks to be constructed on effectively ANY platform that supports docker. 

### launching

"up and running"
```sh
docker run -d -v /dev/net/tun:/dev/net/tun \
  --cap-add NET_ADMIN \ 
  ndru/autotinc
```

### connecting after launching

```sh
docker exec -it CONTAINERID tinc -n autotinc
```

This will drop you to the tinc shell inside the autotinc network. (multiple networks can be configured from the cli)

#### tinc shell commands

```sh
~ $ tincid=$(docker run -d -p 655:655 -v /dev/net/tun:/dev/net/tun --cap-add NET_ADMIN ndru/autotinc:initial)
~ $ docker exec -it $tincid tinc -n autotinc
tinc.autotinc> help
Usage: tinc [options] command

Valid options are:
  -b, --batch             Don't ask for anything (non-interactive mode).
  -c, --config=DIR        Read configuration options from DIR.
  -n, --net=NETNAME       Connect to net NETNAME.
      --pidfile=FILENAME  Read control cookie from FILENAME.
      --force             Force some commands to work despite warnings.
      --help              Display this help and exit.
      --version           Output version information and exit.

Valid commands are:
  init [name]                Create initial configuration files.
  get VARIABLE               Print current value of VARIABLE
  set VARIABLE VALUE         Set VARIABLE to VALUE
  add VARIABLE VALUE         Add VARIABLE with the given VALUE
  del VARIABLE [VALUE]       Remove VARIABLE [only ones with watching VALUE]
  start [tincd options]      Start tincd.
  stop                       Stop tincd.
  restart [tincd options]    Restart tincd.
  reload                     Partially reload configuration of running tincd.
  pid                        Show PID of currently running tincd.
  generate-keys [bits]       Generate new RSA and Ed25519 public/private keypairs.
  generate-rsa-keys [bits]   Generate a new RSA public/private keypair.
  generate-ed25519-keys      Generate a new Ed25519 public/private keypair.
  dump                       Dump a list of one of the following things:
    [reachable] nodes        - all known nodes in the VPN
    edges                    - all known connections in the VPN
    subnets                  - all known subnets in the VPN
    connections              - all meta connections with ourself
    [di]graph                - graph of the VPN in dotty format
    invitations              - outstanding invitations
  info NODE|SUBNET|ADDRESS   Give information about a particular NODE, SUBNET or ADDRESS.
  purge                      Purge unreachable nodes
  debug N                    Set debug level
  retry                      Retry all outgoing connections
  disconnect NODE            Close meta connection with NODE
  top                        Show real-time statistics
  pcap [snaplen]             Dump traffic in pcap format [up to snaplen bytes per packet]
  log [level]                Dump log output [up to the specified level]
  export                     Export host configuration of local node to standard output
  export-all                 Export all host configuration files to standard output
  import                     Import host configuration file(s) from standard input
  exchange                   Same as export followed by import
  exchange-all               Same as export-all followed by import
  invite NODE [...]          Generate an invitation for NODE
  join INVITATION            Join a VPN using an INVITATION
  network [NETNAME]          List all known networks, or switch to the one named NETNAME.
  fsck                       Check the configuration files for problems.
  sign [FILE]                Generate a signed version of a file.
  verify NODE [FILE]         Verify that a file was signed by the given NODE.

Report bugs to tinc@tinc-vpn.org.
tinc.autotinc> network  
autotinc
tinc.autotinc> dump nodes
303efaca61f0 id 0afcbdb5980d at MYSELF port 655 cipher 0 digest 0 maclength 0 compression 0 options 700000c status 0850 nexthop 303efaca61f0 via 303efaca61f0 distance 0 pmtu 9018 (min 0 max 9018)
tinc.autotinc> export
Name = 303efaca61f0
-----BEGIN RSA PUBLIC KEY-----
MIIBCgKCAQEAtTiCNGv66YUgw3bNY+ow0x8fabemVjbEVeqoO0eD3FWGTlD9ASKE
3zXtbqbBdJzi1TDbNT3fPG+xs/mA+O/vOhZRHcG3EX9CH8uqPE4ktjvnh4EcL/uf
XLHLinAjlLYu2WwZGLWIVerU85HjjVeNLbYDW2UOdOqxmvpGJh6Oz4gsTnexl7vG
p5UHkTF8ODTscJAF7V387/dg7YgX5guDLrQy8NPDiRTThUpgQMtdTjBZcPcYXgpf
uhkq2mYrqNQEIMpbwZ3fHWZI5t/FeWnJ0F87NLJcb0HLvaFz/xkuuEpzXXodwTq2
q2rF2SrOK7ACYhv99KHlPRwoyYm4lALC+QIDAQAB
-----END RSA PUBLIC KEY-----
Ed25519PublicKey = i7I1+8fW4Pm6W+14lGQj9EDWB35QyQDBUQG4XhRyQbD
Address = 172.17.0.2
```
 
#### exiting shell

Use CTRL-D to exit the tinc.autotinc> shell. 


## issues

Right now we randomly select an IP in the subnet range of 172.31.255.0/24 to bind to the tunnel interface (autotinc). 


Try out the base tinc container we use [ndru/tinc](https://hub.docker.com/r/ndru/tinc/).
