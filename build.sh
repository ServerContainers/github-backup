#!/bin/sh -x

[ -z "$DOCKER_REGISTRY" ] && echo "error please specify docker-registry DOCKER_REGISTRY" && exit 1
IMG="$DOCKER_REGISTRY/github-backup"

sed -i.bak 's/image: /image: '"$DOCKER_REGISTRY"'\//g' docker-compose.yml; rm docker-compose.yml.bak

PLATFORM="linux/amd64,linux/arm64,linux/arm/v7,linux/arm/v6"

if [ -z ${POSTFIX_VERSION+x} ] || [ -z ${DOVECOT_VERSION+x} ] || [ -z ${ALPINE_VERSION+x} ]; then
  docker-compose build -q --pull --no-cache
  export GITHUBBACKUP_VERSION=$(git log -1 | grep Date: | sed 's/Date://g' | sed 's/[^A-Za-z0-9]//g')
  export ALPINE_VERSION=$(docker run --rm -ti "$IMG" cat /etc/alpine-release | tail -n1 | tr -d '\r')
fi

if echo "$@" | grep -v "force" 2>/dev/null >/dev/null; then
  echo "check if image was already build and pushed - skip check on release version"
  echo "$@" | grep -v "release" && docker pull "$IMG:a$ALPINE_VERSION-g$GITHUBBACKUP_VERSION" 2>/dev/null >/dev/null && echo "image already build" && exit 1
fi

docker buildx build -q --pull --no-cache --platform "$PLATFORM" -t "$IMG:a$ALPINE_VERSION-g$GITHUBBACKUP_VERSION" --push .

echo "$@" | grep "release" 2>/dev/null >/dev/null && echo ">> releasing new latest" && docker buildx build -q --pull --platform "$PLATFORM" -t "$IMG:latest" --push .

git checkout docker-compose.yml