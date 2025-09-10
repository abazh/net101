#!/usr/bin/env python

from mininet.net import Mininet
from mininet.topo import Topo
from mininet.node import Controller, RemoteController, OVSController
from mininet.node import CPULimitedHost, Host, Node
from mininet.node import OVSKernelSwitch, UserSwitch
from mininet.node import IVSSwitch
from mininet.cli import CLI
from mininet.log import setLogLevel, info
from mininet.link import TCLink, Intf
from subprocess import call
from functools import partial
import os

class LinuxRouter( Node ):

    def config( self, **params ):
        super( LinuxRouter, self).config( **params )
        self.cmd( 'sysctl -w net.ipv4.ip_forward=1' )
        self.cmd( 'sysctl -w net.ipv6.conf.all.forwarding=1' )
        self.cmd('/usr/lib/frr/zebra -A 127.0.0.1 -s 90000000 -f /etc/frr/frr.conf -d')
        self.cmd('/usr/lib/frr/staticd -A 127.0.0.1 -f /etc/frr/frr.conf -d')
        self.cmd('/usr/lib/frr/ospfd -A 127.0.0.1 -f /etc/frr/frr.conf -d')
        self.cmd('/usr/lib/frr/ospf6d -A ::1 -f /etc/frr/frr.conf -d')
        self.cmd('/usr/lib/frr/bgpd -A 127.0.0.1 -f /etc/frr/frr.conf -d')
        self.cmd('/usr/lib/frr/pimd -A 127.0.0.1 -f /etc/frr/frr.conf -d')
        self.cmd('/usr/lib/frr/pim6d -A ::1 -f /etc/frr/frr.conf -d')
        self.cmd('/usr/lib/frr/isisd -A 127.0.0.1 -f /etc/frr/frr.conf -d')
       

    def terminate( self ):
        self.cmd( 'killall zebra staticd ospfd ospf6d bgpd pathd pimd pim6d ldpd isisd nhrpd vrrpd fabricd' )

        super( LinuxRouter, self ).terminate()

def run():
    privateDirs = [ ( '/var/log' ),
                    ( '/etc/frr', './frr-config/%(name)s'),
                    ( '/var/run' ),
                      '/var/mn' ]

    net = Mininet(topo=None, autoSetMacs=True)

    info( '*** Add Routers\n')
    r1 = net.addHost('r1', cls=LinuxRouter, ip=None, privateDirs=privateDirs)
    r2 = net.addHost('r2', cls=LinuxRouter, ip=None, privateDirs=privateDirs)

    info( '*** Add hosts\n')
    h1 = net.addHost('h1', cls=Node, ip='192.168.1.2/24', defaultRoute='via 192.168.1.1')
    h2 = net.addHost('h2', cls=Node, ip='192.168.2.2/24', defaultRoute='via 192.168.2.1')

    info( '*** Add links\n')
    net.addLink(h1, r1)
    net.addLink(h2, r2)
    net.addLink(r1, r2)

    info( '*** Starting network\n')
    net.start()
    CLI(net)
    net.stop()

if __name__ == '__main__':
    setLogLevel( 'info' )
    run()
