#!/usr/bin/env make
USAGE_SUMMARY := Easy usage messages for Makefiles.
define USAGE_DESCRIPTION
This library allows you to write \`man\`-like documentation for your Makefile \
includes. To use it, simply include the variables in the Required and Optional \
Environment Variables sections. Do this, and you'll get pretty documentation \
like the one shown in the example. 
endef

define USAGE_REQUIRED_ENV_VARS
<FOO>_SUMMARY: A summary for the include file. This is shown on the top of the documentation entry along with the name of the Makefile include.
endef

define USAGE_OPTIONAL_ENV_VARS
<FOO>_TARGETS: A list of public targets exposed by the Makefile. \
	Wildcard targets will have their percent signs replaced by '<VARIABLE>'.
<FOO>_DESCRIPTION: A longer description of what the file does.
<FOO>_AUTHOR: Author of the Makefile include.
<FOO>_YEAR: Year that the include was originally created.
<FOO>_LICENSE_TEXT: License text that this include is beholden to. \
	Alternatively, you can create a LICENSE file at the root of this repository.
<FOO>_EXAMPLE: A list of examples showing how to use the include.
<FOO>_NOTES: Notes and addendums for your include.
endef

define USAGE_EXAMPLE
Given the file below:

# include/make/foo.mk
 define FOO_USAGE
 Lorem ipsum
 endef

Run the below to get usage documentation for foo.mk:

$$> make foo_help

foo.mk
Loren ipsum

endef

define newline


endef
define tab
	
endef
BOLD_WHITE := \033[1;37m
RESET_COLORS := \033[m
DEFAULT_AUTHOR := The authors.
DEFAULT_YEAR := $(shell date +%Y)


.PHONY: %_help
%_help: USAGE_TO_PRINT=$(shell echo $@ | sed 's/_help$$//' | tr '[:lower:]' '[:upper:]')
%_help: USAGE_TO_PRINT_LCASE=$(shell echo $@ | sed 's/_help$$//')
%_help:
	check_if_empty() { \
		item_to_check="$$1"; \
		if [ -z "$$item_to_check" ]; \
		then \
			echo 'None provided.'; \
		else \
			echo "$$item_to_check"; \
		fi \
	}; \
	check_for_summary() { \
		[ ! -z "$($(USAGE_TO_PRINT)_SUMMARY)" ]; \
	}; \
	print_notes() { \
		notes="$(subst $(newline),\n,$($(USAGE_TO_PRINT)_NOTES))\n\n"; \
		if [ "$$notes" != "" ]; \
		then \
			printf -- "$(BOLD_WHITE)NOTES$(RESET_COLORS)\n\n"; \
			printf -- "$$notes"; \
		fi; \
	}; \
	print_summary() { \
		usage_summary="$($(USAGE_TO_PRINT)_SUMMARY)"; \
		printf -- "$(BOLD_WHITE)NAME$(RESET_COLORS)\n\n"; \
		printf -- "  $(BOLD_WHITE)$(USAGE_TO_PRINT_LCASE)$(RESET_COLORS) -- $$usage_summary\n\n"; \
	}; \
	print_origin() { \
		file_usage_text_is_from=$$(grep -m 1 -lr $(USAGE_TO_PRINT)_SUMMARY $(PWD) | sed 's#$(PWD)/##'); \
		if [ -z "$$file_usage_text_is_from" ]; \
		then \
			>&2 echo "WARN: Couldn't find the file this usage is from?"; \
		fi; \
		printf -- "$(BOLD_WHITE)FROM: $(RESET_COLORS) $$file_usage_text_is_from\n\n"; \
	}; \
	print_description() { \
		if [ "$($(USAGE_TO_PRINT)_DESCRIPTION)" != "" ]; \
		then \
			usage_description="$(subst $(newline),\n,$($(USAGE_TO_PRINT)_DESCRIPTION))"; \
			printf -- "$(BOLD_WHITE)DESCRIPTION$(RESET_COLORS)\n\n"; \
			printf -- "$$usage_description\n\n"; \
		fi; \
	}; \
	print_vars() { \
		type="$${1?Please provide a type.}"; \
		vars="$${2?Please provide some vars to print}"; \
		printf -- "$(BOLD_WHITE)$$(echo $$type | tr [:lower:] [:upper:])$(RESET_COLORS)\n\n"; \
		if [ "$$vars" == "None provided." ]; \
		then \
			printf -- "  None provided.\n"; \
		else \
			printf -- "The following environment variables are $$type:\n\n"; \
			printf -- "$$vars\n" | \
			while read env_var; \
			do \
				key=$$(echo "$$env_var" | cut -f1 -d ':'); \
				value="$$(echo "$$env_var" | sed "s/^$${key}://" | sed 's/^ //')"; \
				length_of_key=$$(echo "$$key" | wc -c); \
				printf -- "  $(BOLD_WHITE)%-30s$(RESET_COLORS) %s\n" "$$key" "$$value"; \
			done; \
		fi; \
		printf -- "\n"; \
	}; \
	print_requireds() { \
		required_vars=$$(check_if_empty "$(subst $(newline),\n,$($(USAGE_TO_PRINT)_REQUIRED_ENV_VARS))"); \
		print_vars "required environment variables" "$$required_vars"; \
	}; \
	print_optionals() { \
		optional_vars=$$(check_if_empty "$(subst $(newline),\n,$($(USAGE_TO_PRINT)_OPTIONAL_ENV_VARS))"); \
		print_vars "optional environment variables" "$$optional_vars"; \
	}; \
	print_examples() { \
		examples=$$(check_if_empty "$(subst $(newline),\n,$($(USAGE_TO_PRINT)_EXAMPLE))"); \
		printf -- "$(BOLD_WHITE)EXAMPLES$(RESET_COLORS)\n\n"; \
		printf -- "  $$examples\n\n"; \
	}; \
	get_default_author() { \
		if [ -f "$(PWD)/AUTHOR" ]; \
		then \
			cat $(PWD)/AUTHOR | tr -d '\n'; \
		else \
			printf "$(DEFAULT_AUTHOR)"; \
		fi; \
	}; \
	print_license() { \
		author_found="$($(USAGE_TO_PRINT)_AUTHOR)"; \
		year_found="$($(USAGE_TO_PRINT)_YEAR)"; \
		author="$${author_found:-$$(get_default_author)}"; \
		year="$${year_found:-$(DEFAULT_YEAR)}"; \
		license="$(subst $(newline),\n,$($(USAGE_TO_PRINT)_LICENSE_TEXT))"; \
		if [ -z "$$license" ]; \
		then \
			if [ ! -f "$(PWD)/LICENSE" ]; \
			then \
				license="No license provided."; \
			else \
				license=$$(cat $(PWD)/LICENSE); \
			fi; \
		fi; \
		printf -- "$(BOLD_WHITE)LICENSE$(RESET_COLORS)\n\n"; \
		printf -- "$${year} $${author}. $$license\n\n"; \
	}; \
	print_targets() { \
		targets_documented=$$(check_if_empty "$(subst $(newline),\n,$($(USAGE_TO_PRINT)_TARGETS))"); \
		targets_documented="$(USAGE_TO_PRINT_LCASE)_help: Displays this usage documentation.\n$${targets_documented}"; \
		print_vars "available targets" "$$targets_documented"; \
	}; \
	print_summary; \
	print_targets; \
	print_origin; \
	print_description; \
	print_requireds; \
	print_optionals; \
	print_examples; \
	print_notes; \
	print_license;
