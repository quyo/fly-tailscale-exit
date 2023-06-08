
fly launch
flyctl secrets set TAILSCALE_AUTH_KEY=tskey-auth-...

fly regions add fra ams lhr ord
fly scale count 4 --max-per-region 1

fly deploy


vor upgrade!
* checken, ob key noch gültig
* scale count 0 + hosts in tailscale löschen

nach upgrade!
* subnet announcement für ams instanz freigeben
* ams ip in tailscale dns settings updaten
