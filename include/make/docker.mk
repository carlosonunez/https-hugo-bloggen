#!/usr/bin/env make
define DOCKER_USAGE
include/make/docker.mk
Interface for running docker actions.

Targets:

  run_docker               Performs a docker run against any file
                           that ends in *.sh or *.bash.

  docker_usage             Displays this help message.

Required Environment Variables:

  ENVIRONMENT_FILE         An environment dotfile to load into the container.

  DOCKER_IMAGE             The image to run for our Docker container.
  
  DOCKER_IMAGE_OPTIONS     Options to provide the container's ENTRYPOINT with.

Optional Environment variables:

  PWD_TO_USE               The directory to set the container's PWD as.
	                         (Default: $(PWD_TO_USE))

  DOCKER_PWD               The directory to mount the host's current working
                           directory into.
                          (Default: $(DOCKER_PWD))

Notes:

- The host's Docker UNIX socket is volume-mounted by default to allow for
  nested container creation. Feel free to remove this to make
  this Make target more secure.

- '--network=host' is turned on by default to allow for easy port allocation
  and networking from nested Docker containers. This might introduce
  security concerns. If it does, consider creating an ephemeral
  Docker network with 'docker network create'.

- Environment dotfiles are volume-mounted into '/env'.
endef
export DOCKER_USAGE
DOCKER_PWD ?= /work
PWD_TO_USE ?= $(PWD)

docker_usage:
	@echo "$$DOCKER_USAGE"
.PHONY: docker_run
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
		--volume $(PWD_TO_USE):$(DOCKER_PWD) \
		--workdir $(DOCKER_PWD) \
		$(DOCKER_IMAGE) $(DOCKER_IMAGE_OPTIONS)
