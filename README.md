# troubleshooting

Imagem Docker para troubleshooting de infraestrutura, rede, bancos e aplicações Java.

Base: **Alpine** (`alpine:3.22.4` no `Dockerfile`).

## Ferramentas embarcadas

- Rede / diagnóstico: `nmap`, `tcpdump`, `hping3`, `iputils`, `bind-tools`, `busybox-extras`, `net-snmp-tools`, `curl`, `wget`
- Clientes DB: `mariadb-client`, `postgresql-client`
- SSH: `openssh-client-default` (cliente)
- Java: `openjdk8-jre-base` (JRE)
- Outros: `bash`, `tar`, `unzip`, `vim`, `aws-cli`

O build espera `flex.tar.gz` na raiz do repositório (conteúdo extraído para `/opt/`). Após instalação dos pacotes extras, é criado `/opt/flex/install.txt` como marcação.

## Imagem publicada (Docker Hub)

O GitHub Actions publica no Docker Hub o repositório de imagem:

`{DOCKERHUB_USERNAME}/troubleshoot`

Substitua `{DOCKERHUB_USERNAME}` pelo utilizador configurado em **Settings → Secrets and variables → Actions** (`DOCKERHUB_USERNAME`).

### Tags por versão

A versão **não** vem do Git tag: vem da **variável de repositório** `TAG_VERSION` (formato `MAJOR.MINOR.PATCH`, por exemplo `2.0.3`; prefixo `v` opcional).

Em cada push bem sucedido na `main`, a pipeline publica:

| Tag Docker | Exemplo (`TAG_VERSION=2.0.3`) |
|------------|------------------------------|
| patch completo | `2.0.3` |
| minor | `2.0` |
| major | `2` |
| última build desta configuração | `latest` |

Atualize `TAG_VERSION` no GitHub **antes** (ou no fluxo combinado pelo time) do merge que deve publicar essa versão.

### Imutabilidade da tag **patch** (CI)

Antes do build, a pipeline confere se a tag **full** (`MAJOR.MINOR.PATCH`, a mesma que vem de `TAG_VERSION`) **já existe** no Docker Hub (`docker manifest inspect`). Se existir, o job **falha** — evita sobrescrever uma versão patch já publicada por engano.

As tags **`:2`**, **`:2.0`** e **`:latest`** continuam a ser **atualizadas** em cada release; só o número **patch completo** é tratado como imutável neste fluxo.

### Versões para testes / uso informal

Para validar imagens sem consumir uma nova patch oficial, pode usar no pull as tags **móveis** que a pipeline mantém, por exemplo:

`docker pull SEU_USUARIO/troubleshoot:2` · `SEU_USUARIO/troubleshoot:2.0` · `SEU_USUARIO/troubleshoot:latest` · ou outra linha já publicada (ex.: `:3`, `:3.1`).

Para **publicar** uma nova imagem com política de patch imutável, incremente sempre `TAG_VERSION` (ex.: `2.0.3` → `2.0.4`). Valores de teste “soltos” no registry podem usar um espaço de versão reservado (ex.: `9.9.1`, `9.9.2`) se o time combinar esse uso.

### Secrets necessários (Actions)

- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN` (token de acesso do Hub com permissão de push)

### Variável de repositório

- **Nome:** `TAG_VERSION` (apenas letras, números e `_`; não use hífen no nome.)
- **Onde:** **Settings → Secrets and variables → Actions → Variables**

### Quando a pipeline **não** corre

Em pushes na `main`, se **todos** os ficheiros alterados estiverem apenas em:

- `.github/workflows/docker-build.yml`
- `.gitignore`
- `.dockerignore`
- `README.md`

…o workflow **não** é disparado. Se o mesmo commit alterar, por exemplo, o `Dockerfile`, a pipeline corre.

### Fluxo sugerido (branch `main` protegida)

1. Branch de trabalho → PR → merge na `main`.
2. Ajustar `TAG_VERSION` quando for publicar uma nova versão semver no Hub.
3. Merge na `main` com alterações que não sejam só os paths ignorados acima → build e push no Docker Hub.

## Build local

Na raiz do clone, com `flex.tar.gz` presente:

```bash
docker build -t troubleshoot:local .
```

## Execução

Exemplo após pull do Hub (substitua o utilizador):

```bash
docker pull SEU_USUARIO/troubleshoot:latest
docker run -it --rm SEU_USUARIO/troubleshoot:latest
```

Versão específica:

```bash
docker pull SEU_USUARIO/troubleshoot:2.0.3
docker run -it --rm SEU_USUARIO/troubleshoot:2.0.3