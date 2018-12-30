PREFIX ?= $(HOME)
MAKE_PATH ?= $(dir $(realpath $(firstword $(MAKEFILE_LIST))))
VIM_PLUGINS = \
	github.com/Raimondi/delimitMate.git \
	github.com/godlygeek/tabular.git \
	github.com/airblade/vim-gitgutter.git \
	github.com/stephpy/vim-yaml.git \
	github.com/terryma/vim-multiple-cursors.git \
	github.com/altercation/vim-colors-solarized.git \
	github.com/nanotech/jellybeans.vim.git \
	github.com/itchyny/lightline.vim.git

###############################################################################
### Install targets
###############################################################################
.PHONY: install
install: install-fonts install-prezto install-vim

.PHONY: install-fonts
install-fonts: ## Installs the powerline fonts
	ln -snf $(MAKE_PATH)fonts $(PREFIX)/fonts
	$(MAKE_PATH)fonts/install.sh

.PHONY: install-prezto
install-prezto: # Installs prezto and zsh configs
	ln -snf $(MAKE_PATH)prezto $(PREFIX)/.zprezto
	ln -snf $(MAKE_PATH)prezto/runcoms/zlogout $(PREFIX)/.zlogout
	ln -snf $(MAKE_PATH)prezto/runcoms/zprofile $(PREFIX)/.zprofile
	ln -snf $(MAKE_PATH)prezto/runcoms/zshenv $(PREFIX)/.zshenv
	ln -snf $(MAKE_PATH)prezto/runcoms/zshrc $(PREFIX)/.zshrc
	ln -snf $(MAKE_PATH)zsh/zlogin $(PREFIX)/.zlogin
	ln -snf $(MAKE_PATH)zsh/zpreztorc $(PREFIX)/.zpreztorc

.PHONY: install-vim
install-vim: # install vim and friends
	ln -snf $(MAKE_PATH)vim $(PREFIX)/.vim
	ln -snf $(MAKE_PATH)vim/vimrc $(PREFIX)/.vimrc

###############################################################################
### Update targets
###############################################################################
.PHONY: update-pathogen
update-pathogen: # Updates the pathogen
	curl -LSso $(MAKE_PATH)vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

###############################################################################
### Targets to rebuild the submodules if required.  Probably won't actually 
### Need them.
###############################################################################
.PHONY: init
init:
	git submodule update --init --recursive

# .PHONY: init-prezto
# init-prezto: # Clone prezto into .zprezto
# 	git submodule add https://github.com/sorin-ionescu/prezto.git

# .PHONY: init-vim-plugins
# init-vim-plugins: $(VIM_PLUGINS) # Add the vim plugins as subtrees
# %.git:
# 	$(MAKE_PATH)init-subtree.sh vim/bundle $@ master
