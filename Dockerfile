FROM alpine:latest

# Repositório edge/testing
RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories

# Atualização base
RUN apk update && apk upgrade

# Ferramentas básicas
RUN apk add bash
RUN apk add nmap
RUN apk add hping3
RUN apk add iputils
RUN apk add busybox-extras
RUN apk add net-snmp-tools
RUN apk add --no-cache curl gnupg
RUN apk add tcpdump
RUN apk add tar

# Java
RUN apk add openjdk8

# Bancos
RUN apk add mysql mysql-client
RUN apk add --update bind-tools postgresql-client

# SSH
RUN apk add openssh

# Diretórios customizados
#RUN mkdir -p /opt/flex

# Arquivos customizados
#COPY Bancos /opt/flex/Bancos
COPY flex.tar.gz /opt/
RUN tar -xzvf /opt/flex.tar.gz -C /opt
RUN rm -f /opt/flex.tar.gz

# Init/OpenRC
COPY inittab /etc/inittab

RUN chmod 644 /etc/inittab
RUN touch /sbin/openrc
RUN chmod +x /sbin/openrc

ENTRYPOINT ["/bin/sh", "-c", "init"]

CMD ["/bin/sh"]
