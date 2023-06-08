
fly launch
flyctl secrets set TAILSCALE_AUTH_KEY=tskey-auth-...

fly scale count 3 --max-per-region 1 --region ams,lhr,ord
fly deploy


vor upgrade!
* checken, ob key noch gültig
* scale count 0 + hosts in tailscale löschen

nach upgrade!
* ams ip in tailscale dns settings updaten
