#!/usr/bin/env make
ENVIRONMENT_SUMMARY := Helps verify and initialize environments

define ENVIRONMENT_TARGETS
check_environment_variable_<ENV_VAR>: Verifies that an environment variable is \
present before running a target.

create_environment_<ENV_NAME>: Creates an environment file from an env.example.
endef

define ENVIRONMENT_OPTIONAL_VARS
ENVIRONMENT: The environment to load. Default is 'local'.
endef

define ENVIRONMENT_NOTES
- You must provide an example environment in your repository called \
	env.example to use this module.
endef

EXAMPLE_ENVIRONMENT_FILE := $(PWD)/env.example
ENVIRONMENT_FILE := $(PWD)/.env

ifeq ("$(wildcard $(EXAMPLE_ENVIRONMENT_FILE))","")
$(error Missing example environment file: $(EXAMPLE_ENVIRONMENT_FILE))
endif

ifeq (,$(wildcard $(ENVIRONMENT_FILE)))
$(error Missing environment file: $(ENVIRONMENT_FILE). \
	To create one, run this: cp $(EXAMPLE_ENVIRONMENT_FILE) $(ENVIRONMENT_FILE))
endif

include $(ENVIRONMENT_FILE)
export $(shell sed 's/=.*//' $(ENVIRONMENT_FILE))

.PHONY: check_environment_variable_%

check_environment_variable_%:
	environment_variable_to_check=$$(echo $@ | sed 's/^check_environment_variable_//'); \
	if ! env | sort -u | grep -Eq "^$$environment_variable_to_check="; \
	then \
		>&2 echo "ERROR: Environment variable not defined: $$environment_variable_to_check"; \
		exit 1; \
	fi