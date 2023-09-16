# Argo tunnel & reverse proxy setup

To avoid exposing ports on firewalls/routers we route all traffic through a Cloudflare Argo Tunnel.
Most of the information is taken from [this reddit tutorial](https://www.reddit.com/r/homelab/comments/pnto6g/how_to_selfhosting_and_securing_web_services_out/).

## SWAG

The tunnel will point to a DigitalOcean droplet running [LinuxServer's SWAG](https://docs.linuxserver.io/general/swag):

```yaml
---
version: "2.1"
services:
  swag:
    image: ghcr.io/linuxserver/swag
    container_name: swag
    cap_add:
      - NET_ADMIN
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Amsterdam
      - URL=bnuuy.net
      - SUBDOMAINS=wildcard
      - VALIDATION=dns
      - DNSPLUGIN=cloudflare
    volumes:
      - ./config:/config
    ports:
      - 443:443
      - 80:80 # optional
	network-mode: "host"
    restart: unless-stopped
```

## Cloudflare Tunnel

Inside the container, `nano /config/dns-conf/cloudlfare.ini` and fill in `dns_cloudflare_email` and `dns_cloudflare_api_key`.

On the host:

1. Set up the [Cloudflare repository](https://pkg.cloudflare.com/) and install cloudflared package: `sudo apt install cloudflared`

2. Setup cloudlfare tunnel:

```shell
$ cloudflared tunnel login
$ cloudflared tunnel create bnuuy
$ cd /etc/cloudflared/
$ ls -la --> get the id (like <tunnel-id>.json)
```

Run `nano config.yml` and fill with:

```yml
tunnel: <tunnel-id>
credentials-file: /root/.cloudflared/<tunnel-id>.json
originRequest:
  originServerName: bnuuy.net
  no-tls-verify: true

ingress:
  - hostname: "*.bnuuy.net"
    service: https://localhost:443
    no-tls-verify: true
  - service: http_status:404
```

3. More cloudflare config

```
$ cloudflared tunnel route dns bnuuy cloud.bnuuy.net
$ cloudflared tunnel run  --> test to see if it works

$ sudo cloudflared service install
$ sudo cp -r ~/.cloudflared/* /etc/cloudflared/  --> todo: is this up to date?
$ sudo nano /etc/cloudflared/config.yml --> change json location
```

We can then manage the `cloudlfared` daemon with:

```shell
sudo systemctl start cloudflared
sudo systemctl enable cloudflared
sudo systemctl status cloudflared
```

Proxy configurations are stored in: `~/docker/swag/config/nginx/proxy-confs`. After a file changes, the system restarts automatically to reflect the changes.

To check for errors: `tail -f ~/docker/swag/config/nginx/log/nginx/error.log`

## TODO

DNS resolution does not work from `nginx` (although it does work from inside the SWAG container).
It may work by setting the appropriate `resolver` directive. This would be a great quality of life improvement, we could just use Tailscale's MagicDNS name to refer to services. For now, we need to use the associated Tailscale IP (thankfully it is static).

## UPDATE local domain

Most domains have been moved to an internal domain. Only accessible via tailscale.
If you go to `non-existent-subdomain.bnuuy.net` (as in, not present in the proxy-confs) you will be redirected to that same subdomain, but on `bnn.net`.

`/config/nginx/site-confs/default.conf`:

```conf
server {

  # other stuff...

  location / {
    # regex the subdomain
    if ($host ~* ^(?!www\.)(?<subdomain>.+)\.bnuuy\.net$) {
      # don't cache the redirect
      add_header Cache-Control "no-cache, no-store, must-revalidate";
      # redirect (NOT PROXY PASS)
      # to let the client resolve the domain
      return 301 http://$subdomain.bnn.net$request_uri;
    }

    # fallback to 404 page
    try_files $uri $uri/ /index.html /index.php?$args =404;
}
```
