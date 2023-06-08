#!/bin/sh

echo 'Starting up tailscale...'

# error: adding [-i tailscale0 -j MARK --set-mark 0x40000] in v4/filter/ts-forward: running [/sbin/iptables -t filter -A ts-forward -i tailscale0 -j MARK --set-mark 0x40000 --wait]: exit status 2: iptables v1.8.6 (legacy): unknown option "--set-mark"
modprobe xt_mark

echo 'net.ipv4.ip_forward = 1' | tee -a /etc/sysctl.conf
echo 'net.ipv6.conf.all.forwarding = 1' | tee -a /etc/sysctl.conf
#echo 'net.ipv6.conf.all.disable_policy = 1' | tee -a /etc/sysctl.conf
sysctl -p /etc/sysctl.conf

iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
ip6tables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

/app/tailscaled --verbose=1 --port 41641 &
sleep 5
if [ ! -S /var/run/tailscale/tailscaled.sock ]; then
    echo "tailscaled.sock does not exist. exit!"
    exit 1
fi

#   --advertise-routes=$(grep fly-local-6pn /etc/hosts | sed -e 's|\s.*||' | cut -d ':' -f 1-3)::/48
until /app/tailscale up \
    --authkey=${TAILSCALE_AUTH_KEY} \
    --hostname=fly-exit-${FLY_REGION} \
    --advertise-exit-node \
    --advertise-routes=fdaa:1:3a1::/48 \
    --ssh
do
    sleep 0.1
done

/app/linux-amd64/dnsproxy -u fdaa::3

echo 'Tailscale started. Lets go!'
sleep infinity

/app/tailscale logout
