PREFIX ?= $(HOME)
MAKE_PATH ?= $(dir $(realpath $(firstword $(MAKEFILE_LIST))))
IOSEVKA_VERSION ?= 2.0.2

###############################################################################
### Install targets
###############################################################################
.PHONY: install
install: install-fonts install-prezto install-vim

.PHONY: install-fonts
install-fonts: ## Installs the powerline fonts
	mkdir -p $(PREFIX)/.local/share
	ln -snf $(MAKE_PATH)fonts $(PREFIX)/.local/share/fonts
	fc-cache

.PHONY: install-prezto
install-prezto: # Installs prezto and zsh configs
	ln -snf $(MAKE_PATH)prezto $(PREFIX)/.zprezto
	ln -snf $(MAKE_PATH)prezto/runcoms/zlogout $(PREFIX)/.zlogout
	ln -snf $(MAKE_PATH)prezto/runcoms/zprofile $(PREFIX)/.zprofile
	ln -snf $(MAKE_PATH)prezto/runcoms/zshenv $(PREFIX)/.zshenv
	ln -snf $(MAKE_PATH)zsh/zshrc $(PREFIX)/.zshrc
	ln -snf $(MAKE_PATH)zsh/zlogin $(PREFIX)/.zlogin
	ln -snf $(MAKE_PATH)zsh/zpreztorc $(PREFIX)/.zpreztorc

.PHONY: install-vim
install-vim: # install vim and friends
	ln -snf $(MAKE_PATH)vim $(PREFIX)/.vim
	ln -snf $(MAKE_PATH)vim/vimrc $(PREFIX)/.vimrc
	sudo ln -snf $(MAKE_PATH)vim /root/.vim
	sudo ln -snf $(MAKE_PATH)vim/vimrc /root/.vimrc

.PHONY: install-rbenv
install-rbenv: # link rbenv to ~/.rbenv and add plugins
	ln -snf $(MAKE_PATH)rbenv $(PREFIX)/.rbenv
	mkdir -p $(MAKE_PATH)rbenv/plugins
	ln -snf $(MAKE_PATH)rbenv-plugins/ruby-build $(MAKE_PATH)rbenv/plugins/ruby-build
	ln -snf $(MAKE_PATH)rbenv-plugins/rbenv-default-gems $(MAKE_PATH)rbenv/plugins/rbenv-default-gems
	@echo
	@echo '##############################################################################'
	@echo '# Ruby Environment                                                           #'
	@echo '##############################################################################'
	@echo 'The rbenv plugin ruby-build requires the following packages are installed:    '
	@echo 'https://github.com/rbenv/ruby-build/wiki#suggested-build-environment          '
	@echo

.PHONY: install-terminal-theme
install-terminal-theme: # Install the gnome terminal theme
	$(MAKE_PATH)extra/jellybeans.sh

###############################################################################
### Update targets
###############################################################################
.PHONY: update
update: update-pathogen update-submodules

.PHONY: update-pathogen
update-pathogen: # Updates the pathogen
	curl -LSso $(MAKE_PATH)vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

.PHONY: update-submodules
update-submodules:
	git submodule update --init --recursive

.PHONY: update-rust
update-rust: # Install rust
	curl https://sh.rustup.rs -sSf | bash -s -- -y --no-modify-path

.PHONY: update-golang
update-golang:
	curl -LSso /tmp/golang.tar.gz https://dl.google.com/go/go1.12.linux-amd64.tar.gz
	tar zxf /tmp/golang.tar.gz -C /tmp
	install -m0755 -D /tmp/go/bin/go* $(PREFIX)/bin

.PHONY: update-fonts
update-fonts: # Install custom fonts
	mkdir /tmp/iosevka
	curl -LSso /tmp/iosevka.zip https://github.com/be5invis/Iosevka/releases/download/v$(IOSEVKA_VERSION)/01-iosevka-$(IOSEVKA_VERSION).zip
	unzip /tmp/iosevka.zip -d /tmp/iosevka
	cp /tmp/iosevka/ttf/* $(MAKE_PATH)/fonts
