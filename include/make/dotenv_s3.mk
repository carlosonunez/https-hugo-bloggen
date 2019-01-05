#!/usr/bin/env make
DOTENV_S3_BUCKET ?= $(shell [ -f .env_info ] && cat .env_info)

.PHONY: get_%_env_vars_from_s3 upload_%_env_vars_to_s3 check_for_dotenv_s3_bucket

get_%_env_vars_from_s3:
	$(MAKE) check_for_dotenv_s3_bucket && \
	$(MAKE) _do_env_vars_s3_action_$$(echo "$@" | cut -f1 -d '_')_$$(echo "$@" | cut -f2 -d '_')

upload_%_env_vars_to_s3:
	$(MAKE) check_for_dotenv_s3_bucket && \
	$(MAKE) _do_env_vars_s3_action_$$(echo "$@" | cut -f1 -d '_')_$$(echo "$@" | cut -f2 -d '_')

check_for_dotenv_s3_bucket:
	if [ -z "$(DOTENV_S3_BUCKET)" ]; \
	then \
		>&2 echo "ERROR: Please provide the path to the S3 bucket containing \
our environment dotfiles. You can either use the DOTENV_S3_BUCKET environment \
variable to do so, or you can write it to .env_info (not tracked by Git)."; \
		exit 1; \
	fi;

.PHONY: _do_env_vars_s3_action_%
_do_env_vars_s3_action_%:
	touch .env && \
	s3_bucket=$(DOTENV_S3_BUCKET); \
	action=$$(echo "$@" | sed 's/_do_env_vars_s3_action_//' | cut -f1 -d '_'); \
	environment_name=$$(echo "$@" | sed 's/_do_env_vars_s3_action_//' | cut -f2 -d '_'); \
	if ! test $$environment_name || ! test $$s3_bucket; \
	then \
		>&2 echo "Usage: DOTENV_S3_BUCKET=$$s3_bucket make $(MAKECMDGOALS)"; \
		exit 1; \
	fi; \
	case "$$action" in \
	get) \
		docker_compose_service="get-dotenv-file-from-s3"; \
		>&2 echo "INFO: Fetching environment vars for [$$environment_name] from S3"; \
		;; \
	upload) \
		sed -i '/^COMMIT_SHA/d' .env; \
		docker_compose_service="upload-dotenv-file-to-s3"; \
		>&2 echo "INFO: Uploading environment vars for [$$environment_name] from S3"; \
		;; \
	*) \
		>&2 echo "ERROR: Invalid action: $$action"; \
		exit 1; \
	esac; \
	ENVIRONMENT_NAME=$$environment_name S3_BUCKET=$$s3_bucket \
		$(DOCKER_COMPOSE_COMMAND) run --rm "$$docker_compose_service"; \
	if [ "$$action" == "get" ]; \
	then \
		echo "COMMIT_SHA=$(COMMIT_SHA)" >> .env; \
	fi;
