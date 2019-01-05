#!/usr/bin/env make
update_env_info_for_ci:
	if [ -z "$(TRAVIS_GITHUB_TOKEN)" ]; \
	then \
		>&2 echo "ERROR: Please provide a GitHub token to use for updating Travis. \
Don't have one? Follow these instructions to create one: \
https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/"; \
		exit 1; \
	fi; \
	TRAVIS_GITHUB_TOKEN=$(TRAVIS_GITHUB_TOKEN) $(DOCKER_COMPOSE_COMMAND) run --rm update-ci-env-info;
