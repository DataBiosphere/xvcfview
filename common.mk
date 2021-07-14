ifeq ($(shell which shellcheck),)
$(error Please install shellcheck using "apt-get install shellcheck" or "brew install shellcheck")
endif
