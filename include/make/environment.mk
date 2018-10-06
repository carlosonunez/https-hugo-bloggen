#!/usr/bin/env make

ifeq ($(ENVIRONMENT),)
ifdef VERBOSE
$(warning An environment name was not provided; assuming local dev)
endif
endif
ENVIRONMENT ?= local

EXAMPLE_ENVIRONMENT_FILE := $(PWD)/env.example
ENVIRONMENT_FILE := $(PWD)/env.$(ENVIRONMENT)

ifeq ("$(wildcard $(EXAMPLE_ENVIRONMENT_FILE))","")
$(error Missing example environment file: $(EXAMPLE_ENVIRONMENT_FILE))
endif

ifeq (,$(wildcard $(ENVIRONMENT_FILE)))
$(error Missing environment file: $(ENVIRONMENT_FILE))
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
