#!/usr/bin/env make

docker_run: \
	check_environment_variable_DOCKER_IMAGE \
	check_environment_variable_DOCKER_IMAGE_OPTIONS

docker_run:
	docker run --tty \
		--rm \
		--network="host" \
		--env-file $(ENVIRONMENT_FILE) \
		--env HOST_PWD=$(PWD) \
		--volume $(ENVIRONMENT_FILE):/env \
		--volume /var/run/docker.sock:/var/run/docker.sock \
		--volume $$(which docker):/usr/bin/docker \
		--volume $(PWD):/work \
		--workdir /work \
		$(DOCKER_IMAGE) $(DOCKER_IMAGE_OPTIONS)
