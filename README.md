Pairing over Tmux for users in different networks (also NAT)
----

Run on some public server

```
docker-compose up
```


Run on client

```
/tmux-share.sh tmux@server 2222
```


Then run on support

```
ssh tmux@localhost -p 2222
```


# refs

based on: https://tqdev.com/2017-helping-friends-on-the-linux-command-line
which based on https://github.com/mevdschee/cli-support/blob/master/socat.sh
alternative: https://github.com/gravitational/teleconsole

