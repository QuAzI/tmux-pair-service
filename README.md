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
