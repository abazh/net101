#! /bin/bash

# Script to connect to a router's bgpd shell.
router=${1:-S1}
cmd=${2:-S2}
echo "Connecting to $router shell"

sudo python3 run.py --node $router --cmd $cmd
