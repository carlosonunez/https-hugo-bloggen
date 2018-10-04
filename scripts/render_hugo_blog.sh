#!/usr/bin/env bash
HUGO_VERSION="${HUGO_VERSION?Please provide a version of Hugo to install.}"
HUGO_THEME_URL="${HUGO_THEME_URL?Please provide the URL of the Hugo theme to use.}"
GENERATED_HUGO_DOCKER_IMAGE_NAME="${GENERATED_HUGO_DOCKER_IMAGE_NAME:-blog_carlosnunez_me}"
LOCAL_PORT_TO_EXPOSE_HUGO_TO="${LOCAL_PORT_TO_EXPOSE_HUGO_TO:-8080}"
ENVIRONMENT_FILE="${ENVIRONMENT_FILE:-/env}"
HUGO_CONTAINER_NAME=hugo-session-$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | head -c 8)
HOST_PWD="${HOST_PWD:-$PWD}"
HUGO_BASE_URL="${HUGO_BASE_URL:-http://localhost}"
NUMBER_OF_TIMES_TO_RETRY_CONNECTING_TO_HUGO=3

display_docker_in_docker_warning() {
  if [ "$HOST_PWD" != "$PWD" ]
  then
    >&2 echo "WARN: A HOST_PWD was provided. This script might be running in a \
  nested Docker container."
  fi
}

usage() {
  cat <<USAGE
$(basename $0)
Locally renders a Hugo site in preparation for hosting on AWS S3 as a \
static website.

Environment variables:

  GENERATED_HUGO_DOCKER_IMAGE_NAME    The name of the ephemeral Docker image
                                      created for hosting your Hugo blog.
                                      (Currently: $GENERATED_HUGO_DOCKER_IMAGE_NAME)

  LOCAL_PORT_TO_EXPOSE_HUGO_TO        The port to expose Hugo on.
                                      (Currently: $LOCAL_PORT_TO_EXPOSE_HUGO_TO)

  HUGO_THEME_URL                      The URL of the theme to download.
                                      (Currently: $HUGO_THEME_URL)

  ENVIRONMENT_FILE                    An environment file containing Hugo
                                      configuration data.
                                      NOTE: config.toml is automatically-generated
                                      when this script runs. Use environment
                                      variables instead.
                                      (Currently: $ENVIRONMENT_FILE)

  HOST_PWD                            The path to the container's working directory
                                      on the *host*. This is needed to ensure
                                      that volume mounts work correctly when
                                      this script is run within a Docker container.

USAGE
}

build_hugo_docker_image() {
  >&2 echo "INFO: Building Hugo Docker image."
  docker build --build-arg HUGO_VERSION="${HUGO_VERSION}" \
    --quiet \
    --tag "$GENERATED_HUGO_DOCKER_IMAGE_NAME" \
    . >/dev/null
}

rebuild_hugo_theme() {
  >&2 echo "INFO: Rebuilding Hugo theme."
  theme_name=$(echo "$HUGO_THEME_URL" | awk -F'/' '{print $NF}' | sed 's/.git//')
  if [ -d site/themes ]
  then
    rm -rf site/themes
  fi
  mkdir site/themes
  git clone -q "$HUGO_THEME_URL" "site/themes/$theme_name" >/dev/null
}

initialize_hugo_config() {
  >&2 echo "INFO: Initializing Hugo config."
  echo '' > site/config.toml
}

start_hugo() {
  >&2 echo "INFO: Starting Hugo."
  docker run \
    --detach \
    --name="${HUGO_CONTAINER_NAME}" \
    --env-file="${ENVIRONMENT_FILE}" \
    --env "HUGO_THEME=$(echo $HUGO_THEME_URL | awk -F'/' '{print $NF}' | sed 's/.git$//')" \
    --volume "$HOST_PWD/site:/site" \
    --publish 8080:8080 \
    ${GENERATED_HUGO_DOCKER_IMAGE_NAME} hugo server --baseURL ${HUGO_BASE_URL} \
      --bind 0.0.0.0 \
      -p 8080 >/dev/null
}

test_hugo() {
  for attempt in $(seq 1 $NUMBER_OF_TIMES_TO_RETRY_CONNECTING_TO_HUGO)
  do
    >&2 echo "INFO: Testing Hugo connectivity (attempt $attempt/$NUMBER_OF_TIMES_TO_RETRY_CONNECTING_TO_HUGO)"
    curl -Lvvv "http://localhost:8080/about" 2>&1 || sleep 0.5
  done
}

stop_hugo() {
  if docker ps | grep -Eq "$HUGO_CONTAINER_NAME"
  then
    >&2 echo "INFO: Stopping Hugo"
    docker rm "$HUGO_CONTAINER_NAME" -f >/dev/null
  fi
}

if [ "$1" == "-h" ] || [ "$1" == "--help" ]
then
  usage
  exit 0
fi

initialize_hugo_config &&
rebuild_hugo_theme &&
build_hugo_docker_image &&
start_hugo &&
test_hugo;
result=$?
stop_hugo
exit $result
