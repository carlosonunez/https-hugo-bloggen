#!/usr/bin/env bash
while read -r kv
do
  export "$kv"
done < <(grep -Ev '^#' "$1" | xargs -0)

if ! grep -Eiq '^true$' <<< "$DOCKER_PUSH_TO_REGISTRY"
then
  >&2 echo "Not pushing to registry; no auth required."
  echo "DOCKER_PUSH_TO_REGISTRY=false"
  exit 0
fi
for var in USERNAME PASSWORD
do
  key="DOCKER_REGISTRY_$var"
  if test -z "${!key}"
  then
    >&2 echo "ERROR: Please define [$key]"
    exit 1
  fi
done
docker login \
  --username "${DOCKER_REGISTRY_USERNAME?Please provide DOCKER_REGISTRY_USERNAME}" \
  --password "${DOCKER_REGISTRY_PASSWORD?Please provide DOCKER_REGISTRY_PASSWORD}" \
  "${DOCKER_REGISTRY_URL:-registry-1.docker.io/v2}"
