LUA_FILES := $(shell find config/nvim -type f -name '*.lua' \
	! -path '*/hidden.lua' | sort)
SHELL_FILES := $(shell find sh -type f -name '*.sh' | sort)

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

check-runtime:
	@./sh/check-runtime.sh

format-lua:
	@stylua $(LUA_FILES)
