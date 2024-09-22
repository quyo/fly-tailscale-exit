ARG TSVERSION=1.74.1
ARG TSFILE=tailscale_${TSVERSION}_amd64.tgz


FROM alpine:latest as tailscale
ARG TSFILE
WORKDIR /app

RUN wget https://pkgs.tailscale.com/stable/${TSFILE} \
 && tar xzf ${TSFILE} --strip-components=1
COPY . ./


FROM alpine:latest
RUN apk update \
 && apk add --no-cache \
      bash \
      bind-tools \
      ca-certificates \
      dante-server \
      dnsmasq \
      iptables \
      ip6tables \
      iproute2 \
      python3 \
      squid \
      tar \
      wget \
 && rm -rf /var/cache/apk/*

# creating directories for tailscale
RUN mkdir -p \
  /var/run/tailscale \
  /var/cache/tailscale \
  /var/lib/tailscale \
  /etc/squid

# Copy binary to production image
COPY --from=tailscale /app/tailscaled /app/tailscaled
COPY --from=tailscale /app/tailscale /app/tailscale

COPY --from=tailscale /app/dnsmasq.conf /etc/dnsmasq.conf
COPY --from=tailscale /app/motd /etc/motd
COPY --from=tailscale /app/sockd.conf /etc/sockd.conf
COPY --from=tailscale /app/squid.conf /etc/squid/squid.conf
COPY --from=tailscale /app/start.sh /app/start.sh

# Run on container startup.
USER root
CMD ["/app/start.sh"]
