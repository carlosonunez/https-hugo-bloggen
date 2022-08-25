#!/usr/bin/env bash
SCRIPT_DIRECTORY=$(dirname "$0")
ENV_PASSWORD="${ENV_PASSWORD?Please provide the password for your env}"
BLOG_GEN_DIRECTORY="${SCRIPT_DIRECTORY}/.."
REPO_NAME="https-hugo-bloggen"
is_running_inside_of_bloggen() {
  ! grep -Eiq  -- "$REPO_NAME" < <(git remote -v)
}

is_running_inside_of_bloggen || fail "You can't run this from bloggen \
itself. Run this from the blog that you're deploying from."

ENV_PASSWORD="${ENV_PASSWORD}" docker-compose \
  -f "$BLOG_GEN_DIRECTORY/docker-compose.ci.yml" \
  run --rm encrypt-env
