#!/usr/bin/env make
.PHONY: update_env_info_for_ci update_aws_env_vars apply_ci_hacks

apply_ci_hacks: _create_site_folder_so_travis_works

update_env_info_for_ci:
	if [ -z "$(TRAVIS_GITHUB_TOKEN)" ]; \
	then \
		>&2 echo "ERROR: Please provide a GitHub token to use for updating Travis. \
Don't have one? Follow these instructions to create one: \
https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/"; \
		exit 1; \
	fi; \
	TRAVIS_GITHUB_TOKEN=$(TRAVIS_GITHUB_TOKEN) $(DOCKER_COMPOSE_RUN_COMMAND) update-ci-env-info;

update_aws_env_vars:
	if [ -z "$(TRAVIS_GITHUB_TOKEN)" ]; \
	then \
		>&2 echo "ERROR: Please provide a GitHub token to use for updating Travis. \
Don't have one? Follow these instructions to create one: \
https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/"; \
		exit 1; \
	fi; \
	TRAVIS_GITHUB_TOKEN=$(TRAVIS_GITHUB_TOKEN) $(DOCKER_COMPOSE_RUN_COMMAND) update-aws-env-vars;

.PHONY: _create_site_folder_so_travis_works

# For some reason, the 'hugo' Docker service gets a permission denied error when
# trying to create the 'site' folder at the root of this repository, even after
# running the Docker Compose service as the 'travis' user (using the
# '--user "$(id -u)"' option). This works fine on my Mac, even without setting
# the --user option explictliy, and, unfortunately, the Docker service
# does not work on OS X (likely due to issues with nesting VMs).
#
# This seems to be unique to Hugo, as the Docker Compose services that retrieve
# my environment dotfile Compose services are able to download and write the
# .env to this directory.
#
# There are two ways I can fix this: explicitly setting the user in the
# 'hugo' Dockerfile using a build argument, or manually creating and permissioning
# the directory in advance. The former option requires shoehorning even more
# stuff into our auto-generated Compose command, so I like the latter approach
# instead.
ifneq ("$(TRAVIS)","")
_create_site_folder_so_travis_works:
	mkdir site && chown -R "$$USER" site
else
_create_site_folder_so_travis_works:
	>&2 echo "WARNING: Not running in Travis; skipping."
endif
