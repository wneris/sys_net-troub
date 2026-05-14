FROM alpine:3.22.4

# edge/testing: hping3
# Pacotes apk sem versão fixa de propósito (imagem de diagnóstico; acompanha atualizações do Alpine).
# hadolint ignore=DL3018
RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories \
    && apk upgrade --no-cache \
    && apk add --no-cache \
        bash \
        bind-tools \
        busybox-extras \
        curl \
        hping3 \
        iputils \
        mariadb-client \
        net-snmp-tools \
        nmap \
        openjdk8-jre-base \
        openssh-client-default \
        postgresql-client \
        tcpdump \
        tar \
        unzip \
        vim \
        wget \
        aws-cli
ADD flex.tar.gz /opt/
RUN echo "tag version validate" > /opt/flex/install.txt

COPY inittab /etc/inittab
RUN chmod 644 /etc/inittab && touch /sbin/openrc && chmod +x /sbin/openrc

ENTRYPOINT ["/bin/sh", "-c", "init"]

CMD ["/bin/sh"]
