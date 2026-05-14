FROM alpine:3.22.4

COPY apk-packages.txt /tmp/apk-packages.txt

# edge/testing: hping3
# Pacotes apk sem versão fixa de propósito (imagem de diagnóstico; acompanha atualizações do Alpine).
# Lista de nomes em apk-packages.txt (hadolint DL3018).
# hadolint ignore=DL3018
RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories \
    && apk upgrade --no-cache \
    && awk '!/^\s*$/ && !/^\s*#/' /tmp/apk-packages.txt > /tmp/pkgs.txt \
    && xargs apk add --no-cache </tmp/pkgs.txt \
    && rm -f /tmp/pkgs.txt

ADD flex.tar.gz /opt/
RUN mkdir -p /opt/flex \
    && awk '!/^\s*$/ && !/^\s*#/' /tmp/apk-packages.txt > /tmp/install-raw.txt \
    && sort -u /tmp/install-raw.txt -o /opt/flex/install.txt \
    && rm -f /tmp/apk-packages.txt /tmp/install-raw.txt

COPY inittab /etc/inittab
RUN chmod 644 /etc/inittab && touch /sbin/openrc && chmod +x /sbin/openrc

ENTRYPOINT ["/bin/sh", "-c", "init"]

CMD ["/bin/sh"]
