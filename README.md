# troubleshooting

Imagem Docker corporativa para troubleshooting de infraestrutura, rede, banco e aplicações Java.

## Ferramentas embarcadas

- nmap
- tcpdump
- hping3
- mysql-client
- postgresql-client
- bind-tools
- openssh
- openjdk8

## Build local

```bash
docker build -t troubleshooting:latest .

## Execução
```bash
docker run -it troubleshooting:latest