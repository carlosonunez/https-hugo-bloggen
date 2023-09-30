#!/usr/bin/env bash
AWS_DOCKER_IMAGE="amazon/aws-cli:2.2.9"
static_dir="$1"
bucket_id="${2:-$(basename "$HUGO_BASE_URL")}"
docker run --rm \
  -v "$static_dir:/work" \
  -w /work \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  -e AWS_SESSION_TOKEN \
  -e AWS_REGION \
  "$AWS_DOCKER_IMAGE" s3 sync "." "s3://$bucket_id"
