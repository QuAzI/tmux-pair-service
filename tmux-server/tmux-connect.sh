#!/bin/sh

if [ -f tmux.port ]; then read -r relay_port < tmux.port; fi
if [ -z "$relay_port" ]; then read -p "Port number: " relay_port ; else echo "Port number: $relay_port" ; fi

/usr/bin/socat open:`tty`,raw,echo=0 tcp-connect:localhost:$relay_port

exit 0
