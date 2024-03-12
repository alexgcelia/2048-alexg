# 2048-alexg
Este repositorio es para la práctica 5.4 de dockerizar una web estática del módulo IAW

## Trabajaremos con un archivo dockerfile
```
FROM ubuntu:23.04

LABEL author=alexg

RUN apt update \
    && apt install git -y \
    && apt install apache2 -y \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/josejuansanchez/2048.git /app \
    && mv /app/* /var/www/html \
        && rm -rf /app

CMD ["/usr/sbin/apache2ctl" , "-D", "FOREGROUND"
```
En el ejecutamos mediante run sentencias anidadas como actualizar repositorios, instalación de git, instalación de apache2 y borrar contenido de los paquetes.
En el siguiente run ejecuta un clone para descargar un repositorio, mueve todo el contenido de app a /var/www/html y borra todo el contenido de app.

## Creamos la imagen a partir del archivo dockerfile
#### Usamos los siguientes comandos:
```
docker build -t nginx-2048 .
```
#### Asignamos una etiqueta
```
docker tag nginx-2048 alexg/2048:1.0
```
o
```
docker tag nginx-2048 alexg/2048:latest
```

## Publicamos la imagen en Docker Hub mediante terminal
### Usamos los siguientes comandos:
#### Ponemos nuestras credenciales de Github
```
docker login
```
#### Realizamos un push
```
docker push alexg/2048:latest
```
### También podemos publicarla mediante Github Actions
#### Esto permite realizar cambios de fuera automatica usando el archivo docker-publish.yml
```
name: Docker

# This workflow uses actions that are not certified by GitHub.
# They are provided by a third-party and are governed by
# separate terms of service, privacy policy, and support
# documentation.

on:
#  schedule:
#    - cron: '20 0 * * *'
  push:
    branches: [ "main" ]
    # Publish semver tags as releass.
    tags: [ 'v*.*.*' ]
  workflow_dispatch:

env:
  # Use docker.io for Docker Hub if empty
  REGISTRY: docker.io
  # github.repository as <account>/<repo>
  IMAGE_NAME: 2048
  IMAGE_TAG: latest


jobs:
  build:

    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
      # This is used to complete the identity challenge
      # with sigstore/fulcio when running outside of PRs.
      id-token: write

    steps:
      - name: Checkout repository
        uses: actions/checkout@v3

      # Set up BuildKit Docker container builder to be able to build
      # multi-platform images and export cache
      # https://github.com/docker/setup-buildx-action
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@f95db51fddba0c2d1ec667646a06c2ce06100226 # v3.0.0

      # Login against a Docker registry except on PR
      # https://github.com/docker/login-action
      - name: Log into registry ${{ env.REGISTRY }}
        if: github.event_name != 'pull_request'
        uses: docker/login-action@343f7c4344506bcbf9b4de18042ae17996df046d # v3.0.0
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      # Build and push Docker image with Buildx (don't push on PR)
      # https://github.com/docker/build-push-action
      - name: Build and push Docker image
        id: build-and-push
        uses: docker/build-push-action@0565240e2d4ab88bba5387d719585280857ece09 # v5.0.0
        with:
          context: .
          push: ${{ github.event_name != 'pull_request' }}
          tags: ${{ env.REGISTRY }}/${{ secrets.DOCKERHUB_USERNAME }}/${{ env.IMAGE_NAME }}:${{ env.IMAGE_TAG }}
          #tags: ${{ steps.meta.outputs.tags }}
          #labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```
