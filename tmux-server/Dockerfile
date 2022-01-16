FROM lscr.io/linuxserver/openssh-server

LABEL mantainer="ruslan.yakauley(at)gmail.com"

RUN apk add --no-cache socat tmux

WORKDIR /app
EXPOSE 2222

COPY motd /etc/motd
COPY tmux-connect.sh . 
RUN ln -s /app/tmux-connect.sh /etc/profile.d/

RUN sed -i 's/AllowTcpForwarding no/AllowTcpForwarding yes/g' /etc/ssh/sshd_config

# CMD [ "/app/tmux-connect.sh" ]
