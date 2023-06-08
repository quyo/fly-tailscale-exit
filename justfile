default: stop start

start:
  fly deploy
  fly scale count 3 --max-per-region 1 --region ams,lhr,ord
  echo "Update nameserver ip for .internal domain via Tailscale dashboard"

stop:
  #!/usr/bin/bash
  fly scale count 0
  read -t 900 -p "Delete machines via Tailscale dashboard now" x
