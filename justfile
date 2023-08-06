default: stop start

start:
  fly deploy --ha=false
  fly scale count 3 --max-per-region 1 --region ams,lhr,ord --yes
  fly logs

stop:
  #!/usr/bin/bash
  fly scale count 0 --yes
  # read -t 900 -p "Delete machines via Tailscale dashboard now" x
