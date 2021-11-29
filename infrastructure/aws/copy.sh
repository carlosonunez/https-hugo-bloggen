#!/usr/bin/env bash
AWS_DOCKER_IMAGE="amazon/aws-cli:2.2.9"
docker run --rm "$AWS_DOCKER_IMAGE" s3 sync "$1" "s3://$(basename "$HUGO_BASE_URL")"
