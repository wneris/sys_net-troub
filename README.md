# troubleshooting

Imagem Docker para troubleshooting de infraestrutura, rede, bancos e aplicações Java.

Base: **Alpine** (`alpine:3.22.4` no `Dockerfile`).

## Ferramentas embarcadas

Os nomes dos pacotes **Alpine (`apk`)** ficam em **`apk-packages.txt`** (um por linha; linhas vazias e `#` comentário são ignoradas no build). Para incluir ou remover ferramentas, edite esse arquivo — o **`Dockerfile`** só precisa mudar quando alterar base, repositórios, arquivos copiados ou a lógica de build.

Resumo do que costuma estar na lista: rede/diagnóstico (`nmap`, `tcpdump`, `hping3`, …), clientes de banco (`mariadb-client`, `postgresql-client`), cliente SSH, JRE 8, `vim`, `wget`, `aws-cli`, etc. — veja o arquivo na raiz do repositório.

O build espera o arquivo `flex.tar.gz` na raiz do repositório (conteúdo extraído para `/opt/`). O arquivo **`/opt/flex/install.txt`** é gerado no build com: (1) a lista pedida em `apk-packages.txt` e (2) a saída de `apk list --installed` (tudo que ficou na imagem).

## Imagem publicada (Docker Hub)

O GitHub Actions publica no Docker Hub a imagem:

`{DOCKERHUB_USERNAME}/troubleshoot`

Substitua `{DOCKERHUB_USERNAME}` pelo **usuário** configurado em **Settings → Secrets and variables → Actions** (`DOCKERHUB_USERNAME`).

### Tags por versão

A versão **não** vem de tag do Git: vem da **variável de repositório** `TAG_VERSION` (formato `MAJOR.MINOR.PATCH`, por exemplo `2.0.3`; prefixo `v` é opcional).

Em cada push **bem-sucedido** na `main`, a pipeline publica:

| Tag Docker | Exemplo (`TAG_VERSION=2.0.3`) |
|------------|------------------------------|
| patch completo | `2.0.3` |
| minor | `2.0` |
| major | `2` |
| última build com essa configuração | `latest` |

Atualize `TAG_VERSION` no GitHub **antes** (ou conforme o fluxo combinado com a equipe) do merge que deve publicar essa versão.

### Imutabilidade da tag **patch** (CI)

Antes do build, a pipeline verifica se a tag **completa** (`MAJOR.MINOR.PATCH`, a mesma de `TAG_VERSION`) **já existe** no Docker Hub (`docker manifest inspect`). Se existir, o job **falha** — evita sobrescrever por engano uma versão patch já publicada.

As tags **`:2`**, **`:2.0`** e **`:latest`** continuam sendo **atualizadas** a cada release; só o número **patch completo** é tratado como imutável neste fluxo.

### Versões para testes / uso informal

Para validar imagens sem gastar uma nova patch oficial, você pode usar no `docker pull` as tags **móveis** que a pipeline mantém, por exemplo:

`docker pull SEU_USUARIO/troubleshoot:2` · `SEU_USUARIO/troubleshoot:2.0` · `SEU_USUARIO/troubleshoot:latest` · ou outra linha já publicada (ex.: `:3`, `:3.1`).

Para **publicar** uma nova imagem com política de patch imutável, sempre incremente `TAG_VERSION` (ex.: `2.0.3` → `2.0.4`). Valores de teste “soltos” no registry podem usar um espaço de versão reservado (ex.: `9.9.1`, `9.9.2`) se a equipe combinar esse uso.

### Secrets necessários (Actions)

- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN` (token de acesso ao Hub com permissão de push)

### Variável de repositório

- **Nome:** `TAG_VERSION` (apenas letras, números e `_`; não use hífen no nome.)
- **Onde:** **Settings → Secrets and variables → Actions → Variables**

### Quando a pipeline **não** roda

Em pushes na `main`, se **todos** os arquivos alterados estiverem **somente** em:

- `.github/workflows/docker-build.yml`
- `.github/workflows/lint.yml`
- `.gitignore`
- `.dockerignore`
- `README.md`

…o workflow de build da imagem **não** é acionado. Se o mesmo commit alterar, por exemplo, o `Dockerfile`, a pipeline de build roda.

### Fluxo sugerido (branch `main` protegida)

1. Branch de trabalho → PR → merge na `main`.
2. Ajustar `TAG_VERSION` quando for publicar uma nova versão semver no Hub.
3. Merge na `main` com mudanças que não sejam só nos caminhos ignorados acima → build e push no Docker Hub.

## Lint (CI)

Em **pull requests** e **pushes** na `main`, o workflow `lint.yml` executa o **actionlint** (arquivos em `.github/workflows/`) e o **hadolint** (`Dockerfile`). O hadolint usa `failure-threshold: error` (avisos não fazem o job falhar).

## Build local

Na raiz do clone, com `flex.tar.gz` presente:

```bash
docker build -t troubleshoot:local .
```

## Execução

Exemplo após `pull` do Hub (substitua o usuário):

```bash
docker pull SEU_USUARIO/troubleshoot:latest
docker run -it --rm SEU_USUARIO/troubleshoot:latest
```

Versão específica:

```bash
docker pull SEU_USUARIO/troubleshoot:2.0.3
docker run -it --rm SEU_USUARIO/troubleshoot:2.0.3
```
