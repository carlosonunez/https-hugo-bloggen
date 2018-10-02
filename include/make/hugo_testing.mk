#!/usr/bin/env make
HUGO_SUMMARY := Create test Hugo blogs with Make through Docker.
HUGO_TARGETS := create_test_hugo_server: Initializes a long-running test Hugo server.
HUGO_REQUIRED_ENV_VARS := ENVIRONMENT_FILE: A path to a dotenv file. \
	(Automatic if using the environment.mk module.)

.PHONY: create_test_hugo_server
create_test_hugo_server:
	docker run --tty \
		--rm \
		--network="host" \
		--env-file $(ENVIRONMENT_FILE) \
		--env HOST_PWD=$(PWD) \
		--env KEEP_HUGO_SERVER_ALIVE_FOR_TESTING=true \
		--volume $(ENVIRONMENT_FILE):/env \
		--volume /var/run/docker.sock:/var/run/docker.sock \
		--volume $$(which docker):/usr/bin/docker \
		--volume $(PWD):/work \
		--workdir /work \
		--entrypoint sh \
		$(BATS_DOCKER_IMAGE) scripts/render_hugo_blog.sh
