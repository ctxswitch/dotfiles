PREFIX ?= $(HOME)
MAKE_PATH ?= $(dir $(realpath $(firstword $(MAKEFILE_LIST))))

.PHONY: install
install: install-fonts install-prezto

.PHONY: install-fonts
install-fonts: ## Installs the powerline fonts
	ln -sf $(MAKE_PATH)fonts $(HOME)/fonts
	$(MAKE_PATH)fonts/install.sh

.PHONY: install-prezto
install-prezto: # Installs prezto and zsh configs
	ln -sf $(MAKE_PATH)prezto $(HOME)/.zprezto
	ln -sf $(MAKE_PATH)prezto/runcoms/zlogout $(HOME)/.zlogout
	ln -sf $(MAKE_PATH)prezto/runcoms/zprofile $(HOME)/.zprofile
	ln -sf $(MAKE_PATH)prezto/runcoms/zshenv $(HOME)/.zshenv
	ln -sf $(MAKE_PATH)prezto/runcoms/zshrc $(HOME)/.zshrc
	ln -sf $(MAKE_PATH)zsh/zlogin $(HOME)/.zlogin
	ln -sf $(MAKE_PATH)zsh/zpreztorc $(HOME)/.zpreztorc
