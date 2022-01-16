#!/bin/bash
#
# Run this script on guest side to create shared session
# based on: https://tqdev.com/2017-helping-friends-on-the-linux-command-line
# alternative: https://github.com/gravitational/teleconsole
#
# BUG: only one detach per session allowed by SOCAT

checkDependency () {
    if [ ! -f $1 ]; then
        echo "$1 required"
        exit 1
    fi
}

checkDependency /usr/bin/ssh
checkDependency /usr/bin/tmux
checkDependency /usr/bin/socat


# find first free port
read lower_port upper_port < /proc/sys/net/ipv4/ip_local_port_range
for (( port = lower_port ; port <= upper_port ; port++ )); do
	export relay_port=$port
	nc -zv localhost $port 2>/dev/null ; if [ $? -eq 1 ]; then break; fi
done


if [ ! -z "$1" ]; then export relay_server=$1 ; else read -p "SSH Server: " relay_server ; fi
if [ ! -z "$2" ]; then export ssh_port=$2 ; else read -p "SSH port: " ssh_port; fi
export tmux_session=support-$relay_port

if [ -z "$relay_server" ] || [ -z "$ssh_port" ]; then
    echo All parameters required
    exit 1
fi

tmux has-session -t $tmux_session 2>/dev/null
if [ $? != 0 ]; then
    tmux new-session -d -s $tmux_session
fi


socat exec:"tmux attach -t $tmux_session",pty,raw,echo=0,stderr,setsid,sigint,sane \
    tcp-listen:$relay_port,bind=localhost,reuseaddr &

export SOCAT_PID=$!


echo "Starting new session on $relay_server:$ssh_port to share port $relay_port"
export remote_port=$relay_port
ssh -R $remote_port:localhost:$relay_port -N $relay_server -p $ssh_port -f "echo $remote_port > tmux.port"

export SSH_PID=$! SSH_CODE=$?

if [ $SSH_CODE -eq 0 ]; then
    tmux attach -t $tmux_session
else
    echo "SSH Connection failed for $tmux_session"
fi


if [ -z "$tmux_session" ]; then tmux kill-session -t $tmux_session 2>/dev/null ; fi
kill $SSH_PID $SOCAT_PID

exit 0
