#!/usr/bin/env make
DOCKER_SUMMARY := Interact with Docker in Make.
DOCKER_TARGETS := docker_run: Executes 'docker run'.
define DOCKER_REQUIRED_ENV_VARS
ENVIRONMENT_FILE: The environment to use (automatic if using environment.mk)
DOCKER_IMAGE: The image to create our container from.
DOCKER_IMAGE_OPTIONS: Options to provide to the container's ENTRYPOINT.
endef
define DOCKER_OPTIONAL_ENV_VARS
PWD_TO_USE: The container's PWD. Default is your current working directory.
DOCKER_PWD: The name of the mount point PWD_TO_USE uses within the container. \
	(Default: $(DOCKER_PWD))
endef
define DOCKER_EXAMPLE
The following will create a container for 'jq':

$$> DOCKER_IMAGE=jq make docker_run

The following will create a container for 'jq' and use /tmp as the \
container's PWD:

$$> DOCKER_IMAGE=jq PWD_TO_USE=/tmp make docker_run

The following will do the above, but use '/foo' as the directory /tmp is \
volume mounted into:

$$> DOCKER_IMAGE=jq DOCKER_PWD=/foo PWD_TO_USE=/tmp make docker_run
endef
define DOCKER_NOTES
- All containers launched by docker_run are non-interactive and allocate a \
  pseudo-TTY.
endef

DOCKER_PWD ?= /work
PWD_TO_USE ?= $(PWD)

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
