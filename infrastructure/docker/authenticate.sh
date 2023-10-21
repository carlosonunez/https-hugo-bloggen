#!/usr/bin/env bash
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
>&2 docker login \
  --username "${DOCKER_REGISTRY_USERNAME?Please provide DOCKER_REGISTRY_USERNAME}" \
  --password "${DOCKER_REGISTRY_PASSWORD?Please provide DOCKER_REGISTRY_PASSWORD}" \
  "${DOCKER_REGISTRY_URL:-docker.io}"
