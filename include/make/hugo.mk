#!/usr/bin/env make
HUGO_SUMMARY := Create test Hugo blogs with Make through Docker.
HUGO_TARGETS := create_test_hugo_server: Initializes a long-running test Hugo server.
HUGO_REQUIRED_ENV_VARS := ENVIRONMENT_FILE: A path to a dotenv file. \
	(Automatic if using the environment.mk module.)

.PHONY: \
	setup_hugo_test_environment \
	teardown_hugo_test_environment \
	generate_hugo_static_files \
	deploy_hugo_static_files

setup_hugo_test_environment: _generate_hugo_configs
setup_hugo_test_environment:
		HUGO_VERSION="$(HUGO_VERSION)" docker-compose up -d hugo-tests
teardown_hugo_test_environment:
		HUGO_VERSION="$(HUGO_VERSION)" docker-compose down hugo-tests && rm -rf "$$PWD/site"
generate_blog:
		HUGO_VERSION="$(HUGO_VERSION)" docker-compose run -d hugo-generate
deploy_hugo_static_files: check_environment_variable_BUCKET_TO_DEPLOY_TO
deploy_hugo_static_files:
	BUCKET_TO_DEPLOY_TO="$(BUCKET_TO_DEPLOY_TO)" docker-compose run hugo-deploy

.PHONY: _generate_hugo_configs
_generate_hugo_configs:
	rm -f config.toml && docker-compose run --rm hugo-generate-test-configs;
