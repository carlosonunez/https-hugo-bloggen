#!/usr/bin/env bash
docker_image_name="$(basename "$HUGO_BASE_URL"):$VERSION"
>&2 echo "INFO: Building Docker image [$docker_image_name]"
docker build -t "$docker_image_name" \
  --build-arg HUGO_BASE_URL="$HUGO_BASE_URL" \
  -f "./infrastructure/docker/Dockerfile" "$1"
if grep -Eiq '^true$' <<< "$DOCKER_PUSH_TO_REGISTRY"
then
  remote_image_name="${DOCKER_REGISTRY_URL:-docker.io}/${DOCKER_REGISTRY_USERNAME}/$docker_image_name"
  >&2 echo "INFO: Pushing Docker image [$remote_image_name] to ${DOCKER_REGISTRY_URL:-docker.io}"
  docker tag "$docker_image_name" "$remote_image_name"
  docker push "$remote_image_name"
fi
