#!/bin/sh
#
# Run this script on relay_server to connect shared session
#

read -p "Port number: " relay_port

socat file:`tty`,raw,echo=0 tcp-connect:localhost:${relay_port}