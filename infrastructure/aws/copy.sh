#!/usr/bin/env bash
AWS_DOCKER_IMAGE="amazon/aws-cli:2.2.9"
set -x
docker run --rm \
  -v "$1:/work" \
  -w /work \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  -e AWS_SESSION_TOKEN \
  -e AWS_REGION \
  "$AWS_DOCKER_IMAGE" s3 sync "." "s3://$(basename "$HUGO_BASE_URL")"
