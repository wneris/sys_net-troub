FROM alpine:3.21

# edge/testing: hping3
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
        unzip

COPY flex.tar.gz /opt/
RUN tar -xzf /opt/flex.tar.gz -C /opt && rm -f /opt/flex.tar.gz
RUN echo "OPA" > /opt/flex/opa.txt

COPY inittab /etc/inittab
RUN chmod 644 /etc/inittab && touch /sbin/openrc && chmod +x /sbin/openrc

ENTRYPOINT ["/bin/sh", "-c", "init"]

CMD ["/bin/sh"]
