#!/usr/bin/env make
.PHONY: \
  create_env \
  get_integration_env \
  get_production_env \
  update_test_env \
  update_integration_env \
  update_production_env

create_env:
	sed 's/ #.*$$//; /^#/d; /^$$/d' env.example > .env;

get_test_env: get_test_env_vars_locally
get_integration_env: get_integration_env_vars_from_s3
get_production_env: get_production_env_vars_from_s3
update_integration_env: upload_integration_env_vars_to_s3
update_production_env: upload_production_env_vars_to_s3


get_%_env_vars_locally:
	environment_name=$$(echo "$@" | cut -f2 -d _); \
	file_to_find=$$PWD/.env.$$environment_name; \
	if [ ! -f "$$file_to_find" ]; \
	then \
		>&2 echo "ERROR: $$file_to_find not found."; \
		exit 1; \
	fi; \
	cp "$$file_to_find" .env; \
	echo "COMMIT_SHA=$(COMMIT_SHA)" >> .env

