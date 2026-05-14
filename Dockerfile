FROM alpine:3.22.4

COPY apk-packages.txt /tmp/apk-packages.txt

# edge/testing: hping3
# Pacotes apk sem versão fixa de propósito (imagem de diagnóstico; acompanha atualizações do Alpine).
# Lista de nomes em apk-packages.txt (hadolint DL3018).
# hadolint ignore=DL3018
RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories \
    && apk upgrade --no-cache \
    && apk add --no-cache \
        $(grep -v '^\s*#' /tmp/apk-packages.txt | grep -v '^\s*$' | tr '\n' ' ')

ADD flex.tar.gz /opt/
RUN mkdir -p /opt/flex \
    && { \
      echo "# Pacotes pedidos (apk-packages.txt) — $(date -u +%Y-%m-%dT%H:%MZ) UTC"; \
      grep -v '^\s*#' /tmp/apk-packages.txt | grep -v '^\s*$' | sort -u; \
      echo ""; \
      echo "# Todos os pacotes instalados na imagem (apk list --installed) —"; \
      apk list --installed | sort -u; \
    } > /opt/flex/install.txt \
    && rm -f /tmp/apk-packages.txt

COPY inittab /etc/inittab
RUN chmod 644 /etc/inittab && touch /sbin/openrc && chmod +x /sbin/openrc

ENTRYPOINT ["/bin/sh", "-c", "init"]

CMD ["/bin/sh"]
