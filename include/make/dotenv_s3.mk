#!/usr/bin/env make
DOTENV_S3_BUCKET ?= $(shell cat .env_info)
.PHONY: \
	get_%_env_vars_from_s3 \
	upload_%_env_vars_to_s3

get_%_env_vars_from_s3:
	touch .env && \
	s3_bucket=$(DOTENV_S3_BUCKET); \
	verb=$$(echo "$@" | cut -f1 -d _); \
	environment_name=$$(echo "$@" | cut -f2 -d _); \
	direction=$$(echo "$@" | cut -f5 -d _); \
	if ! test $$environment_name || ! test $$s3_bucket; \
	then \
		>&2 echo "Usage: DOTENV_S3_BUCKET=$$s3_bucket make $(MAKECMDGOALS)"; \
		exit 1; \
	fi; \
	>&2 echo "INFO: Fetching environment vars for [$$environment_name] from S3"; \
	ENVIRONMENT_NAME=$$environment_name S3_BUCKET=$$s3_bucket \
		$(DOCKER_COMPOSE_COMMAND) run --rm "$$verb-dotenv-file-$$direction-s3" && \
	echo "COMMIT_SHA=$(COMMIT_SHA)" >> .env

upload_%_env_vars_to_s3:
	if [ ! -f .env ]; \
	then \
		>&2 echo "ERROR: Please provide a .env to upload."; \
		exit 1; \
	fi; \
	s3_bucket=$(DOTENV_S3_BUCKET); \
	verb=$$(echo "$@" | cut -f1 -d _); \
	environment_name=$$(echo "$@" | cut -f2 -d _); \
	direction=$$(echo "$@" | cut -f5 -d _); \
	if ! test $$environment_name || ! test $$s3_bucket; \
	then \
		>&2 echo "Usage: DOTENV_S3_BUCKET=$$s3_bucket make $(MAKECMDGOALS)"; \
		exit 1; \
	fi; \
	>&2 echo "INFO: Updating environment vars for [$$environment_name] from S3"; \
	sed -i '/^COMMIT_SHA/d' .env && \
		ENVIRONMENT_NAME=$$environment_name \
		S3_BUCKET=$$s3_bucket \
		$(DOCKER_COMPOSE_COMMAND) run --rm "$$verb-dotenv-file-$$direction-s3"
