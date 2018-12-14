#!/usr/bin/env make
HUGO_SUMMARY := Create test Hugo blogs with Make through Docker.
HUGO_TARGETS := create_test_hugo_server: Initializes a long-running test Hugo server.
HUGO_REQUIRED_ENV_VARS := ENVIRONMENT_FILE: A path to a dotenv file. \
	(Automatic if using the environment.mk module.)

.PHONY: setup_hugo_test_environment
setup_hugo_test_environment: _initialize_hugo _start_hugo
clear_hugo_site: _clear_hugo_site

.PHONY: _initialize_hugo _create_test_post _start_hugo

_initialize_hugo:
	rm -rf site && \
	for folder in layouts themes; \
	do \
		mkdir -p "site/$$folder" && cp -R "$$folder" "site/$$folder"; \
	done && \
	if [ ! -f site/config.toml ]; \
	then \
		touch site/config.toml; \
	fi;

_create_test_post:
	mkdir -p site/content/post && \
		cp -Rv tests/fixtures/test_post.md site/content/post

_start_hugo:
	ENVIRONMENT_FILE=$(ENVIRONMENT_FILE) docker-compose up -d hugo

_render_hugo:
	docker-compose up -d hugo_render
