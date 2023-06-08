ARG TSVERSION=1.42.0
ARG TSFILE=tailscale_${TSVERSION}_amd64.tgz


FROM alpine:latest as tailscale
ARG TSFILE
WORKDIR /app

RUN wget https://pkgs.tailscale.com/stable/${TSFILE} \
 && tar xzf ${TSFILE} --strip-components=1
COPY . ./


FROM alpine:latest
RUN apk update && apk add bash bind-tools ca-certificates iptables ip6tables iproute2 tar wget \
 && rm -rf /var/cache/apk/*

# Copy binary to production image
COPY --from=tailscale /app/start.sh /app/start.sh
COPY --from=tailscale /app/tailscaled /app/tailscaled
COPY --from=tailscale /app/tailscale /app/tailscale
RUN mkdir -p /var/run/tailscale
RUN mkdir -p /var/cache/tailscale
RUN mkdir -p /var/lib/tailscale

# Install dnsproxy
ENV DNSPROXYVERSION=v0.49.2
WORKDIR /app
RUN wget https://github.com/AdguardTeam/dnsproxy/releases/download/${DNSPROXYVERSION}/dnsproxy-linux-amd64-${DNSPROXYVERSION}.tar.gz \
 && tar xzf dnsproxy-linux-amd64-${DNSPROXYVERSION}.tar.gz --strip-components=1

# Run on container startup.
USER root
CMD ["/app/start.sh"]
