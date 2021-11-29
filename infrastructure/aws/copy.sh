#!/usr/bin/env bash
docker-compose run --rm aws s3 sync "$1" "s3://$(basename "$HUGO_BASE_URL")"
