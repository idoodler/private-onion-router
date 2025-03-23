FROM alpine:latest as build
WORKDIR /app

RUN curl -fsSL https://tailscale.com/install.sh | sh


FROM alpine:3.18

RUN apk --no-cache add \
      tor \
      torsocks \
    && rm -rf /var/cache/apk/* \
      /tmp/* \
      /var/tmp/*

RUN sed "1s/^/SocksPort 127.0.0.1:9050\nControlPort 127.0.0.1:9051\n/" /etc/tor/torrc.sample > /etc/tor/torrc \
    &&  sed -i "s|#%include /etc/torrc.d/\*.conf|%include /etc/torrc.d/\*.conf|g" /etc/tor/torrc \
    &&  mkdir -p /etc/torrc.d

VOLUME ["/etc/torrc.d"]
VOLUME ["/var/lib/tor"]

COPY start.sh /app/start.sh
COPY --from=build /app/tailscaled /app/tailscaled
COPY --from=build /app/tailscale /app/tailscale

ENTRYPOINT ["/app/start.sh"]

