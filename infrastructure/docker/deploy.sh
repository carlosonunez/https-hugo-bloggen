#!/usr/bin/env bash

while read -r kv
do
  export "$kv"
done < <(egrep -Ev '^#' "$2" | xargs -0)

docker_image_name="$(basename "$HUGO_BASE_URL"):$VERSION"
>&2 echo "INFO: Building Docker image [$docker_image_name]"
docker build -t "$docker_image_name" \
  --build-arg HUGO_BASE_URL="$HUGO_BASE_URL" \
  -f "./infrastructure/docker/Dockerfile" "$1"
if grep -Eiq '^true$' <<< "$DOCKER_PUSH_TO_REGISTRY"
then
  >&2 echo "INFO: Pushing Docker image [$docker_image_name] to ${DOCKER_REGISTRY_URL}"
  docker tag "$docker_image_name" "${DOCKER_REGISTRY_USERNAME}/$docker_image_name"
  docker push "${DOCKER_REGISTRY_USERNAME}/$docker_image_name"
fi
