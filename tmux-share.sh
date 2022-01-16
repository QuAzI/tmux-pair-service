#!/bin/sh
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

if [ ! -z "$1" ]; then export relay_server=$1 ; else read -p "SSH Server: " relay_server ; fi
if [ ! -z "$2" ]; then export relay_port=$2 ; else read -p "Shared port: " relay_port; fi
if [ ! -z "$3" ]; then export tmux_session=$3 ; else export tmux_session=support-${relay_port} ; fi

if [ -z "$relay_server" ] || [ -z "$relay_port" ]; then
    echo All parameters required
    exit 1
fi

tmux has-session -t ${tmux_session} 2>/dev/null
if [ $? != 0 ]; then
    tmux new-session -d -s ${tmux_session}
fi

socat exec:"tmux attach -t ${tmux_session}",pty,raw,echo=0,stderr,setsid,sigint,sane \
    tcp-listen:${relay_port},bind=localhost,reuseaddr &

export SOCAT_PID=$!


echo "Starting new session on ${relay_server} to share port ${relay_port}"
ssh -R ${relay_port}:localhost:${relay_port} -N ${relay_server} -f


export SSH_PID=$! SSH_CODE=$?

if [ $SSH_CODE -eq 0 ]; then
    echo "Attach to tmux session ${tmux_session}"
    tmux attach -t ${tmux_session}
else
    echo "SSH session failed"
fi


if [ -z "$3" ]; then tmux kill-session -t ${tmux_session} 2>/dev/null ; fi
kill ${SSH_PID} ${SOCAT_PID}

exit 0