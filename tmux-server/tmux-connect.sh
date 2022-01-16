#!/bin/sh
#
# Run this script on relay_server to connect shared session
#

if [ -f tmux.port ]; then read -r relay_port < tmux.port; fi
if [ -z "$relay_port" ]; then read -p "Port number: " relay_port ; else echo "Port number: $relay_port" ; fi

/usr/bin/socat file:`tty`,raw,echo=0 tcp-connect:localhost:$relay_port

exit 0
