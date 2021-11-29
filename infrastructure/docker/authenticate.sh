#!/usr/bin/env bash
while read -r kv
do
  export "$kv"
done < <(egrep -Ev '^#' "$ENVIRONMENT_FILE" | xargs -0)

if ! grep -Eiq '^true$' <<< "$DOCKER_PUSH_TO_REGISTRY"
then
  >&2 echo "Not pushing to registry; no auth required."
  exit 0
fi
docker login \
  --username "${DOCKER_REGISTRY_USERNAME?Please provide DOCKER_REGISTRY_USERNAME}" \
  --password "${DOCKER_REGISTRY_PASSWORD?Please provide DOCKER_REGISTRY_PASSWORD}" \
  "${DOCKER_REGISTRY_URL:-registry-1.docker.io/v2}"
