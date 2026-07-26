LUA_FILES := $(shell find config/nvim -type f -name '*.lua' \
	! -path '*/hidden.lua' | sort)
SHELL_FILES := $(shell find sh -type f -name '*.sh' | sort)
NVIM ?= nvim
NVIM_VERSION ?=
DEPDIR ?= .test-deps
CURL ?= curl -fL --retry 5 --retry-delay 5 --retry-connrefused --create-dirs

ifeq ($(shell uname -s),Darwin)
  ifeq ($(shell uname -m),arm64)
    NVIM_ARCH ?= macos-arm64
  else
    NVIM_ARCH ?= macos-x86_64
  endif
else
  NVIM_ARCH ?= linux-x86_64
endif

ifneq ($(NVIM_VERSION),)
  NVIM_DIR := $(DEPDIR)/nvim-$(NVIM_VERSION)-$(NVIM_ARCH)
  NVIM_STAMP := $(NVIM_DIR)/.installed
  NVIM_TARBALL := $(NVIM_DIR).tar.gz
  NVIM_URL := https://github.com/neovim/neovim/releases/download/$(NVIM_VERSION)/nvim-$(NVIM_ARCH).tar.gz
  CHECK_NVIM := $(NVIM_DIR)/nvim-$(NVIM_ARCH)/bin/nvim
  CHECK_NVIM_DEPS := $(NVIM_STAMP)
else
  CHECK_NVIM := $(NVIM)
  CHECK_NVIM_DEPS :=
endif

.PHONY: install update check check-lua check-shell check-install check-runtime format-lua

install:
	@./sh/install.sh

update:
	@./sh/update.sh

check: check-lua check-shell check-install check-runtime

check-lua:
	@luacheck $(LUA_FILES)
	@stylua --check $(LUA_FILES)

check-shell:
	@shellcheck $(SHELL_FILES)

check-install:
	@./sh/check-install.sh

check-runtime: $(CHECK_NVIM_DEPS)
	@NVIM="$(CHECK_NVIM)" ./sh/check-runtime.sh

format-lua:
	@stylua $(LUA_FILES)

ifneq ($(NVIM_VERSION),)
$(NVIM_STAMP):
	$(CURL) "$(NVIM_URL)" -o "$(NVIM_TARBALL)"
	rm -rf "$(NVIM_DIR)"
	mkdir -p "$(NVIM_DIR)"
	tar -xf "$(NVIM_TARBALL)" -C "$(NVIM_DIR)"
	rm -f "$(NVIM_TARBALL)"
	touch "$@"
endif
