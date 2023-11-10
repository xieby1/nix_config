# Tailscale/Headscale

## overview

* client
  * tailscale
  * tailscaled
* server
  * headscale

## Command

TODO: exit node
* https://www.reddit.com/r/Tailscale/comments/w9mtow/question_about_headscale_and_routing/
* https://icloudnative.io/posts/how-to-set-up-or-migrate-headscale/

TODO: headtail config
TODO: nix config

* rootless service
* root service

```bash
tailscale --socket /tmp/tailscaled.sock up --login-server http://82.157.197.100
tailscale --socket /tmp/tailscaled.sock up --login-server http://82.157.197.100 --force-reauth
```

### enable routes, exit node

sudo tailscale --socket /tmp/tailscaled.sock up --login-server http://82.157.197.100 --advertise-routes=0.0.0.0/0,::/0 --accept-routes=true

sudo docker exec headscale headscale nodes routes enable -i 13 -a -r 0.0.0.0/0 -r ::/0


