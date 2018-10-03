#!/usr/bin/env bash
ENVIRONMENT_FILE="${ENVIRONMENT_FILE?Please provide a dotenv.}"
HUGO_THEME_URL="${HUGO_THEME_URL?Please provide the URL of the Hugo theme to use.}"
GENERATED_HUGO_DOCKER_IMAGE_NAME="${GENERATED_HUGO_DOCKER_IMAGE_NAME:-blog_carlosnunez_me}"
LOCAL_PORT_TO_EXPOSE_HUGO_TO="${LOCAL_PORT_TO_EXPOSE_HUGO_TO:-8080}"

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

USAGE
}

build_docker_image_for_site() {
  docker build -t "$GENERATED_HUGO_DOCKER_IMAGE_NAME" . -f-<<DOCKER_IMAGE
FROM publysher/hugo
DOCKER_IMAGE
}

rebuild_hugo_theme() {
  theme_name=$(echo "$HUGO_THEME_URL" | awk -F'/' '{print $NF}' | sed 's/.git//')
  if [ -d site/themes ]
  then
    rm -rf site/themes
  fi
  mkdir site/themes
  git clone "$HUGO_THEME_URL" "site/themes/$theme_name"
}

rebuild_config_toml() {
  echo '' > site/config.toml
}

run_hugo_from_docker_image() {
  docker run --rm \
    --detach \
    --publish ${LOCAL_PORT_TO_EXPOSE_HUGO_TO}:1313 \
    "${GENERATED_HUGO_DOCKER_IMAGE_NAME}" >/dev/null
  if ! curl -L https://localhost:$(LOCAL_PORT_TO_EXPOSE_HUGO_TO)
  then
    >&2 echo "ERROR: Hugo didn't start."
    return 1
  fi
}

if [ "$1" == "-h" ] || [ "$1" == "--help" ]
then
  usage
  exit 0
fi

if ! {
  rebuild_config_toml &&
  rebuild_hugo_theme &&
  build_docker_image_for_site && 
  run_hugo_from_docker_image;  
}
then
  >&2 echo "ERROR: Failed to start Hugo; see logs above."
  exit 1
fi

exit 0
