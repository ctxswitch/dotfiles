PREFIX := $(HOME)
MAKE_PATH := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))
SHELL := /bin/bash

include $(MAKE_PATH).local

OS_NAME := $(shell uname -s)
OS_NAME_LOWER := $(shell echo $(OS_NAME) | tr A-Z a-z)
OS_DIST ?= $(shell uname)
ifeq ($(OS_NAME), Darwin)
RELEASE := $(shell lsb_release -cs)
ALTERNATE_RELEASE ?= cosmic
endif

KUBERNETES_RELEASE ?= $(shell curl -L -s https://dl.k8s.io/release/stable.txt)
KUBECTL_URL ?= https://storage.googleapis.com/kubernetes-release/release/$(KUBERNETES_RELEASE)/bin/$(OS_NAME_LOWER)/amd64/kubectl
KIND_VERSION ?= 0.10.0
DOCKER_MACHINE_VERSION ?= v0.16.0

VAGRANT_VERSION ?= 2.2.4
TERRAFORM_VERSION ?= 0.12.4
PACKER_VERSION ?= 1.4.1
CHEFDK_VERSION ?= 3.10.1
CHEFDK_DEB_REVISION ?= 1
RUBY_VERSIONS ?= 2.4.5 2.5.3 2.6.1
RUBY_GEMS ?= rake bundler
GOLANG_VERSION ?= 1.16.4

HUGO_VERSION ?= 0.55.6

FEX_VERSION ?= 2.0.0

GIT_USER_NAME ?= Anonymous
GIT_USER_EMAIL ?= anonymous@gmail.com
GIT_USER_SIGNINGKEY ?= A1E2B3BFE2AF174D

IOSEVKA_VERSION ?= 6.1.3
IOSEVKA_PATH := https://github.com/be5invis/Iosevka/releases/download/v$(IOSEVKA_VERSION)/01-iosevka-$(IOSEVKA_VERSION).zip
ifeq ($(OS_NAME), Darwin)
FONT_PATH := $(PREFIX)/Library/Fonts
else
FONT_PATH := $(PREFIX)/.local/share/fonts
endif

ifeq ($(OS_NAME), Darwin)
HUGO_PATH := https://github.com/gohugoio/hugo/releases/download/v$(HUGO_VERSION)/hugo_$(HUGO_VERSION)_Linux-64bit.deb
HUGO_FILE := hugo.deb
else
HUGO_PATH := https://github.com/gohugoio/hugo/releases/download/v$(HUGO_VERSION)/hugo_$(HUGO_VERSION)_macOS-64bit.tar.gz
HUGO_FILE := hugo.tar.gz
endif

VSCODE_EXTENSIONS ?= bungcip.better-toml eamodio.gitlens \
	golang.go hashicorp.terraform ms-azuretools.vscode-docker \
	ms-python.python ms-python.vscode-pylance ms-vscode.cpptools \
	ms-vsliveshare.vsliveshare rebornix.ruby redhat.vscode-yaml \
	rust-lang.rust sidneys1.gitconfig swashata.beautiful-ui \
	teabyii.ayu vscode-icons-team.vscode-icons wingrunr21.vscode-ruby \
	GitHub.github-vscode-theme
ifeq ($(OS_NAME), Darwin)
VSCODE_CONFIG_PATH ?= Library/Application Support/Code/User
else
VSCODE_CONFIG_PATH ?= $(HOME)/.config/Code/User
endif

include ./mk/Makefile.$(OS_NAME_LOWER)

.PHONY: all ## Run all configuration and installation targets
all: install configure

###############################################################################
### Fonts
###############################################################################
.PHONY: fonts ## Installs the iosevka fonts
fonts:
ifndef SUDO_USER
ifeq ($(OS_NAME), Darwin)
	ln -snfF $(MAKE_PATH)fonts $(FONT_PATH)
else
	mkdir -p $(PREFIX)/.local/share
	ln -snf $(MAKE_PATH)fonts $(FONT_PATH)
	fc-cache
endif
endif

###############################################################################
### Configure
###############################################################################
.PHONY: configure
configure: configure-wm configure-zsh configure-vim configure-tmux configure-git

.PHONY: configure-wm
configure-wm: ## Remove ubuntu themed gnome for vanilla
ifeq ($(OS_NAME), Linux)
ifdef SUDO_USER
	# Update the settings if we are not running in superuser mode.
	gsettings set org.gnome.desktop.interface gtk-theme Yaru-dark
	gsettings set org.gnome.desktop.interface monospace-font-name 'Iosevka 13'
	gsettings set org.gnome.desktop.peripherals.touchpad click-method fingers
	gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
	gsettings set org.gnome.desktop.background show-desktop-icons false
	gsettings set org.gnome.desktop.wm.keybindings switch-windows-backward "['<Shift><Alt><Super>i']"
	gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-up "['<Primary><Alt>i']"
	gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-down "['<Primary><Alt>k']"
	gsettings set org.gnome.desktop.wm.keybindings switch-windows "['<Alt><Super>i']"
	
	$(MAKE_PATH)gnome/jellybeans-term.sh
endif
else
	@echo "Skipping window manager setup"
endif

.PHONY: configure-zsh
configure-zsh:
ifndef SUDO_USER
	ln -snf $(MAKE_PATH)prezto $(PREFIX)/.zprezto
	ln -snf $(MAKE_PATH)prezto/runcoms/zlogout $(PREFIX)/.zlogout
	ln -snf $(MAKE_PATH)prezto/runcoms/zprofile $(PREFIX)/.zprofile
	ln -snf $(MAKE_PATH)prezto/runcoms/zshenv $(PREFIX)/.zshenv
	ln -snf $(MAKE_PATH)zsh/zshrc $(PREFIX)/.zshrc
	ln -snf $(MAKE_PATH)zsh/zlogin $(PREFIX)/.zlogin
	ln -snf $(MAKE_PATH)zsh/zpreztorc $(PREFIX)/.zpreztorc
endif

.PHONY: configure-vim
configure-vim:
ifndef SUDO_USER
	ln -snf $(MAKE_PATH)vim $(PREFIX)/.vim
	ln -snf $(MAKE_PATH)vim/vimrc $(PREFIX)/.vimrc
endif

.PHONY: configure-tmux
configure-tmux:
ifndef SUDO_USER
	ln -snf $(MAKE_PATH)tmux $(PREFIX)/.tmux
	ln -snf $(MAKE_PATH)tmux/tmux.conf $(PREFIX)/.tmux.conf
endif

.PHONY: configure-git
configure-git:
ifndef SUDO_USER
	@awk \
		-v name=$(GIT_USER_NAME) \
		-v email=$(GIT_USER_EMAIL) \
		-v key=$(GIT_USER_SIGNING_KEY) \
		-v github=$(GITHUB_USER) \
		'{ \
				gsub("##GIT_USER_NAME##",name); \
				gsub("##GIT_USER_EMAIL##",email); \
				gsub("##GIT_USER_SIGNINGKEY##",key); \
				gsub("##GITHUB_USER##",github); \
				print \
		}' git/.gitconfig > $(MAKE_PATH)tmp/gitconfig
		install $(MAKE_PATH)tmp/gitconfig $(PREFIX)/.gitconfig
endif

.PHONY: configure-vscode
configure-vscode:
ifndef SUDO_USER
	@for ext in $(VSCODE_EXTENSIONS); do \
		code --install-extension $$ext ;\
	done
	ln -snf $(MAKE_PATH)vscode/settings.json "$(PREFIX)/$(config_path)/settings.json"
	ln -snf $(MAKE_PATH)vscode/keybindings.json "$(PREFIX)/$(config_path)/keybindings.json"
endif

.PHONY: configure-rbenv
configure-rbenv:
ifndef SUDO_USER
	ln -snf $(MAKE_PATH)rbenv $(PREFIX)/.rbenv
	mkdir -p $(MAKE_PATH)rbenv/plugins
	ln -snf $(MAKE_PATH)rbenv-plugins/ruby-build $(MAKE_PATH)rbenv/plugins/ruby-build
	ln -snf $(MAKE_PATH)rbenv-plugins/rbenv-default-gems $(MAKE_PATH)rbenv/plugins/rbenv-default-gems
	
	@for version in $(RUBY_VERSIONS); do \
		rbenv install --skip-existing $$version ;\
		for gem in $(RUBY_GEMS); do \
			RBENV_VERSION=$$version rbenv exec gem install $$gem ;\
		done ;\
	done

	rbenv global 2.6.1
	rbenv rehash
endif

###############################################################################
### Install
###############################################################################
.PHONY: install
install: install-packages install-fex install-rust install-golang install-hugo \
	install-k8s install-docker install-hashicorp-packages install-google-cloud-sdk

.PHONY: install-packages ## Install packages
install-packages:
ifeq ($(OS_NAME), Linux)
ifdef SUDO_USER
	snap install spotify
	snap install slack --classic
	snap install code --classic
	snap install pencilsheep
	apt -y install zsh vim tmux xsel pinentry-tty pinentry-curses \
		pinentry-gnome3 zeal jq git apt-transport-https ca-certificates curl \
		software-properties-common build-essential autoconf bison build-essential \
		libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev \
		libffi-dev libgdbm6 libgdbm-dev python3 python3-pip python3-virtualenv \
		libvirt-clients libvirt-daemon-system libvirt-dev qemu-kvm qemu-utils qemu
	pip3 install pre-commit
	usermod -a -G kvm $(SUDO_USER)
	usermod -a -G libvirt $(SUDO_USER)
endif
else
ifndef SUDO_USER
	NONINTERACTIVE=1 ./brew/install.sh
	xcode-select --install
	curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh | bash
	brew install zsh
	brew install python3
	brew install git
	brew install jq
endif
endif

.PHONY: install-wm
install-wm: ## Remove ubuntu themed gnome for vanilla
ifeq ($(OS_NAME), Linux)
ifdef SUDO_USER
	apt -y remove gnome-shell-extension-ubuntu-dock
	apt -y install gnome-session
	apt -y install gnome-tweak-tool
	# Get rid of wayland and go back to xorg due to incompatibilities.
	install -m 0644 $(MAKE_PATH)gnome/custom.conf /etc/gdm3/custom.conf
	ln -snf /usr/share/xsessions/gnome-xorg.desktop /usr/share/xsessions/gnome.desktop
endif
else
	@echo "Skipping window manager setup"
endif

.PHONY: install-fex ## Install fex (Field EXtractor)
install-fex:
ifdef SUDO_USER
	curl -LSso tmp/fex.tar.gz https://github.com/jordansissel/fex/archive/v$(FEX_VERSION).tar.gz
	tar zxvf tmp/fex.tar.gz -C tmp
	make -C tmp/fex-$(FEX_VERSION) fex
	make -C tmp/fex-$(FEX_VERSION) fex.1
	make -C tmp/fex-$(FEX_VERSION) install
endif

.PHONY: install-rust ## Install the Rust programming language
rust:
ifndef SUDO_USER
	curl https://sh.rustup.rs -sSf | bash -s -- -y --no-modify-path
endif

.PHONY: install-golang ## Install the Go programming language
golang:
ifdef SUDO_USER
	curl -LSso tmp/golang.tar.gz https://dl.google.com/go/go$(GOLANG_VERSION).$(OS_NAME_LOWER)-amd64.tar.gz
	mkdir -p /usr/local/go
	tar zxf tmp/golang.tar.gz --strip 1 -C /usr/local/go
endif

.PHONY: install-hugo ## Install the hugo static site generator
install-hugo:
ifdef SUDO_USER
	curl -LSso $(MAKE_PATH)tmp/$(HUGO_FILE) $(HUGO_PATH)
ifeq ($(OS_NAME), Linux)
	apt -y install $(MAKE_PATH)tmp/$(HUGO_FILE)
else
	@echo "TODO"
endif
endif

.PHONY: install-k8s
install-k8s: ## Installs kubectl and local testing tools
ifdef SUDO_USER
	curl -LSso /tmp/kind https://kind.sigs.k8s.io/dl/v$(KIND_VERSION)/kind-$(OS_NAME_LOWER)-amd64
	chmod +x /tmp/kind && mv /tmp/kind /usr/local/bin/kind
	curl -LSso $(MAKE_PATH)tmp/kubectl $(KUBECTL_URL
	install $(MAKE_PATH)tmp/kubectl /usr/local/bin/kubectl
endif

.PHONY: install-docker
install-docker: ## Installs docker
ifdef SUDO_USER
ifeq ($(OS_NAME), Linux)
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
	install -D $(MAKE_PATH)sources.list.d/docker.$(ALTERNATE_RELEASE).list /etc/apt/sources.list.d
	apt-get -y update
	apt -y install docker-ce
	usermod -a -G docker $(SUDO_USER)
	curl -LSso $(MAKE_PATH)tmp/docker-machine https://github.com/docker/machine/releases/download/$(DOCKER_MACHINE_VERSION)/docker-machine-Linux-x86_64
	install $(MAKE_PATH)tmp/docker-machine /usr/local/bin/docker-machine
else
	curl -LSso $(PREFIX)/Desktop/docker.dmg https://desktop.docker.com/mac/stable/amd64/Docker.dmg
endif
endif

.PHONY: install-hashicorp-packages
install-hashicorp-packages: ## Installs important hashicorp tools
ifdef SUDO_USER
ifeq ($(OS_NAME), Linux)
	curl -LSso $(MAKE_PATH)tmp/vagrant.deb https://releases.hashicorp.com/vagrant/$(VAGRANT_VERSION)/vagrant_$(VAGRANT_VERSION)_x86_64.deb
	apt -y install $(MAKE_PATH)tmp/vagrant.deb
	curl -LSso $(MAKE_PATH)tmp/terraform.zip https://releases.hashicorp.com/terraform/$(TERRAFORM_VERSION)/terraform_$(TERRAFORM_VERSION)_linux_amd64.zip
	unzip -u $(MAKE_PATH)tmp/terraform.zip -d $(MAKE_PATH)tmp
	install $(MAKE_PATH)tmp/terraform /usr/local/bin/terraform
	curl -LSso $(MAKE_PATH)tmp/packer.zip https://releases.hashicorp.com/packer/$(PACKER_VERSION)/packer_$(PACKER_VERSION)_linux_amd64.zip
	unzip -u $(MAKE_PATH)tmp/packer.zip -d $(MAKE_PATH)tmp
	install $(MAKE_PATH)tmp/packer /usr/local/bin/packer
else
	brew tap hashicorp/tap
	brew install hashicorp/tap/vagrant
	brew install hashicorp/tap/terraform
	brew install hashicorp/tap/packer
endif
endif

.PHONY: install-google-cloud-sdk
install-google-cloud-sdk: ## Install the google cloud sdk (gcloud, gsutil, etc)
ifdef SUDO_USER
ifeq ($(OS_NAME), Linux)
	curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
	install -D $(MAKE_PATH)sources.list.d/google-cloud.$(RELEASE).list /etc/apt/sources.list.d
	apt-get -y update
	apt -y install google-cloud-sdk
else
	curl -LSso tmp/google-cloud-sdk.tar.gz https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-340.0.0-darwin-x86_64.tar.gz
	tar zxvf tmp/google-cloud-sdk.tar.gz -C tmp
	./tmp/google-cloud-sdk/install.sh
endif
endif

###############################################################################
### Update
###############################################################################
.PHONY: update ## Run all update targets
update: update-pathogen update-submodules update-fonts

.PHONY: update-pathogen ## Updates pathogen
update-pathogen:
	curl -LSso $(MAKE_PATH)vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

.PHONY: update-submodules ## Update all the submodules
update-submodules:
	git submodule update --init --recursive

.PHONY: update-fonts ## Update custom fonts
update-fonts:
	mkdir /tmp/iosevka
	curl -LSso /tmp/iosevka.zip $(IOSEVKA_PATH)
	unzip /tmp/iosevka.zip -d /tmp/iosevka
	rsync -av --delete /tmp/iosevka/ttf/* $(MAKE_PATH)/fonts

###############################################################################
### Clean
###############################################################################
.PHONY: clean # Clean up any temporary files
clean:
	rm -rf tmp/*
