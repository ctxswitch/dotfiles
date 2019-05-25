PREFIX := $(HOME)
MAKE_PATH := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))
RELEASE := $(shell lsb_release -cs)
SHELL := /bin/bash

include $(MAKE_PATH).local
ALTERNATE_RELEASE ?= cosmic
KUBECTL_VERSION ?= $(shell curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)
DOCKER_MACHINE_VERSION ?= v0.16.0
VAGRANT_VERSION ?= 2.2.4
TERRAFORM_VERSION ?= 0.11.14
PACKER_VERSION ?= 1.4.1
CHEFDK_VERSION ?= 3.10.1
CHEFDK_DEB_REVISION ?= 1
RUBY_VERSIONS ?= 2.5.3 2.6.1
RUBY_GEMS ?= rake bundler
HUGO_VERSION ?= 0.55.6
FEX_VERSION ?= 2.0.0
GIT_USER_NAME ?= Anonymous
GIT_USER_EMAIL ?= anonymous@gmail.com
GIT_USER_SIGNINGKEY ?= A1E2B3BFE2AF174D
VSCODE_EXTENSIONS ?= bungcip.better-toml dasfranck.jellybeans \
		karyfoundation.theme-karyfoundation-themes mauve.terraform pendrica.chef \
		rebornix.ruby rust-lang.rust sidneys1.gitconfig teabyii.ayu ms-vscode.go \
		craigmaslowski.erb ms-vscode.cpptools

.PHONY: install
install: fonts terminal packages gnome devtools languages

###############################################################################
### Terminal tools/utilities/shell
###############################################################################
.PHONY: terminal
terminal: zsh vim tmux

.PHONY: zsh
zsh: ## Installs prezto and zsh configs
ifdef SUDO_USER
	apt -y install zsh
else
	ln -snf $(MAKE_PATH)prezto $(PREFIX)/.zprezto
	ln -snf $(MAKE_PATH)prezto/runcoms/zlogout $(PREFIX)/.zlogout
	ln -snf $(MAKE_PATH)prezto/runcoms/zprofile $(PREFIX)/.zprofile
	ln -snf $(MAKE_PATH)prezto/runcoms/zshenv $(PREFIX)/.zshenv
	ln -snf $(MAKE_PATH)zsh/zshrc $(PREFIX)/.zshrc
	ln -snf $(MAKE_PATH)zsh/zlogin $(PREFIX)/.zlogin
	ln -snf $(MAKE_PATH)zsh/zpreztorc $(PREFIX)/.zpreztorc
endif

.PHONY: vim
vim: ## Install vim and friends
ifdef SUDO_USER
	apt -y install vim
else
	ln -snf $(MAKE_PATH)vim $(PREFIX)/.vim
	ln -snf $(MAKE_PATH)vim/vimrc $(PREFIX)/.vimrc
endif

.PHONY: tmux
tmux: ## Install and configure tmux
ifdef SUDO_USER
	apt -y install tmux xsel
else
	ln -snf $(MAKE_PATH)tmux $(PREFIX)/.tmux
	ln -snf $(MAKE_PATH)tmux/tmux.conf $(PREFIX)/.tmux.conf
endif

.PHONY: gpg
gpg:
ifdef SUDO_USER
	apt -y install pinentry-tty pinentry-curses pinentry-gnome3
endif

###############################################################################
### Fonts
###############################################################################
.PHONY: fonts
fonts: ## Installs the iosevka fonts
ifndef SUDO_USER
	mkdir -p $(PREFIX)/.local/share
	ln -snf $(MAKE_PATH)fonts $(PREFIX)/.local/share/fonts
	fc-cache
endif

###############################################################################
### Non specific packages
###############################################################################
.PHONY: packages
packages: snap-packages apt-packages

.PHONY: snap-packages
snap-packages: ## Installs non-specific packages through snap.
ifdef SUDO_USER
	snap install spotify
	snap install slack --classic
	snap install pencilsheep
endif

.PHONY: apt-packages
apt-packages: ## Install non-specific packages through apt
ifdef SUDO_USER
	apt -y install zeal jq
endif

.PHONY: source
source: ## Temporary spot for building packages from source
# TODO: figure out a better way to handle generic builds
ifdef SUDO_USER
	curl -LSso tmp/fex.tar.gz https://github.com/jordansissel/fex/archive/v$(FEX_VERSION).tar.gz
	tar zxvf tmp/fex.tar.gz -C tmp
	make -C tmp/fex-$(FEX_VERSION) fex
	make -C tmp/fex-$(FEX_VERSION) fex.1
	make -C tmp/fex-$(FEX_VERSION) install
endif

###############################################################################
# Gnome setup
###############################################################################
.PHONY: gnome
gnome: ## Remove ubuntu themed gnome for vanilla and add custom settings
ifdef SUDO_USER
	apt -y remove gnome-shell-extension-ubuntu-dock
	apt -y install gnome-session
	apt -y install gnome-tweak-tool
	# Get rid of wayland and go back to xorg due to incompatibilities.
	install -m 0644 $(MAKE_PATH)gnome/custom.conf /etc/gdm3/custom.conf
	ln -snf /usr/share/xsessions/gnome-xorg.desktop /usr/share/xsessions/gnome.desktop
else
	# Update the settings if we are not running in superuser mode.
	gsettings set org.gnome.desktop.interface gtk-theme Yaru-dark
	gsettings set org.gnome.desktop.interface monospace-font-name 'Iosevka 13'
	gsettings set org.gnome.desktop.peripherals.touchpad click-method fingers
	gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
	gsettings set org.gnome.desktop.background show-desktop-icons false
	$(MAKE_PATH)gnome/jellybeans-term.sh
endif

###############################################################################
# Development tools
###############################################################################
.PHONY: devtools
devtools: build-deps vscode virtual docker kubernetes hashicorp chefdk

.PHONY: git
git:
ifdef SUDO_USER
	apt -y install git
else
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

.PHONY: build-deps
build-deps: ## Package dependencies
ifdef SUDO_USER
	apt -y install apt-transport-https ca-certificates curl software-properties-common
	apt -y install build-essential
endif

.PHONY: vscode
vscode: ## Installs VSCode
ifdef SUDO_USER
	snap install code --classic
else
	@for ext in $(VSCODE_EXTENSIONS); do \
		code --install-extension $$ext ;\
	done
	ln -snf $(MAKE_PATH)vscode/settings.json $(PREFIX)/.config/Code/User/settings.json
endif

.PHONY: virtual
virtual: ## Installs libvirt and friends
ifdef SUDO_USER
	apt -y install libvirt-clients libvirt-daemon-system libvirt-dev qemu-kvm qemu-utils qemu
	usermod -a -G kvm $(SUDO_USER)
	usermod -a -G libvirt $(SUDO_USER)
endif

.PHONY: docker
docker: ## Installs docker
ifdef SUDO_USER
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
	install -D $(MAKE_PATH)sources.list.d/docker.$(ALTERNATE_RELEASE).list /etc/apt/sources.list.d
	apt-get -y update
	apt -y install docker-ce
	usermod -a -G docker $(SUDO_USER)
endif

.PHONY: kubernetes
kubernetes: ## Installs kubectl and local testing tools
ifdef SUDO_USER
	curl -LSso $(MAKE_PATH)tmp/minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
	install $(MAKE_PATH)tmp/minikube /usr/local/bin/minikube
	curl -LSso $(MAKE_PATH)tmp/kubectl https://storage.googleapis.com/kubernetes-release/release/$(KUBECTL_VERSION)/bin/linux/amd64/kubectl
	install $(MAKE_PATH)tmp/kubectl /usr/local/bin/kubectl
	curl -LSso $(MAKE_PATH)tmp/docker-machine https://github.com/docker/machine/releases/download/$(DOCKER_MACHINE_VERSION)/docker-machine-Linux-x86_64
	install $(MAKE_PATH)tmp/docker-machine /usr/local/bin/docker-machine
	curl -LSso $(MAKE_PATH)tmp/docker-machine-driver-kvm2 https://storage.googleapis.com/minikube/releases/latest/docker-machine-driver-kvm2
	install $(MAKE_PATH)tmp/docker-machine-driver-kvm2 /usr/local/bin/docker-machine-driver-kvm2
endif

.PHONY: hashicorp
hashicorp: ## Installs important hashicorp tools
ifdef SUDO_USER
	curl -LSso $(MAKE_PATH)tmp/vagrant.deb https://releases.hashicorp.com/vagrant/$(VAGRANT_VERSION)/vagrant_$(VAGRANT_VERSION)_x86_64.deb
	apt -y install $(MAKE_PATH)tmp/vagrant.deb
	curl -LSso $(MAKE_PATH)tmp/terraform.zip https://releases.hashicorp.com/terraform/$(TERRAFORM_VERSION)/terraform_$(TERRAFORM_VERSION)_linux_amd64.zip
	unzip -u $(MAKE_PATH)tmp/terraform.zip -d $(MAKE_PATH)tmp
	install $(MAKE_PATH)tmp/terraform /usr/local/bin/terraform
	curl -LSso $(MAKE_PATH)tmp/packer.zip https://releases.hashicorp.com/packer/$(PACKER_VERSION)/packer_$(PACKER_VERSION)_linux_amd64.zip
	unzip -u $(MAKE_PATH)tmp/packer.zip -d $(MAKE_PATH)tmp
	install $(MAKE_PATH)tmp/packer /usr/local/bin/packer
endif

.PHONY: chefdk
chefdk: ## Install the chef development kit
ifdef SUDO_USER
	curl -LSso $(MAKE_PATH)tmp/chefdk.deb https://packages.chef.io/files/stable/chefdk/$(CHEFDK_VERSION)/ubuntu/18.04/chefdk_$(CHEFDK_VERSION)-$(CHEFDK_DEB_REVISION)_amd64.deb
	apt -y install $(MAKE_PATH)tmp/chefdk.deb
endif

.PHONY: google-cloud-sdk
google-cloud-sdk: ## Install the google cloud sdk (gcloud, gsutil, etc)
ifdef SUDO_USER
	curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
	install -D $(MAKE_PATH)sources.list.d/google-cloud.$(RELEASE).list /etc/apt/sources.list.d
	apt-get -y update
	apt -y install google-cloud-sdk
endif

.PHONY: hugo
hugo:
ifdef SUDO_USER
	curl -LSso $(MAKE_PATH)tmp/hugo.deb https://github.com/gohugoio/hugo/releases/download/v$(HUGO_VERSION)/hugo_$(HUGO_VERSION)_Linux-64bit.deb
	apt -y install $(MAKE_PATH)tmp/hugo.deb
endif

###############################################################################
# Development languages
###############################################################################
.PHONY: languages
languages: ruby rust golang

.PHONY: ruby
ruby: ## link rbenv to ~/.rbenv and add plugins
ifdef SUDO_USER
	apt-get -y install autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev \
		zlib1g-dev libncurses5-dev libffi-dev libgdbm6 libgdbm-dev
else
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

.PHONY: rust
rust: ## Install rust
ifndef SUDO_USER
	curl https://sh.rustup.rs -sSf | bash -s -- -y --no-modify-path
endif

.PHONY: golang
golang:
ifndef SUDO_USER
	curl -LSso /tmp/golang.tar.gz https://dl.google.com/go/go1.12.linux-amd64.tar.gz
	mkdir -p $(PREFIX)/go
	tar zxf /tmp/golang.tar.gz --strip 1 -C $(PREFIX)/go
endif

###############################################################################
### Update targets
###############################################################################
.PHONY: update
update: update-pathogen update-submodules update-fonts

.PHONY: update-pathogen
update-pathogen: ## Updates the pathogen
	curl -LSso $(MAKE_PATH)vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

.PHONY: update-submodules
update-submodules: ## Update all the submodules
	git submodule update --init --recursive

.PHONY: update-fonts
update-fonts: ## Install custom fonts
	mkdir /tmp/iosevka
	curl -LSso /tmp/iosevka.zip https://github.com/be5invis/Iosevka/releases/download/v$(IOSEVKA_VERSION)/01-iosevka-$(IOSEVKA_VERSION).zip
	unzip /tmp/iosevka.zip -d /tmp/iosevka
	rsync -av --delete /tmp/iosevka/ttf/* $(MAKE_PATH)/fonts

###############################################################################
### Clean targets
###############################################################################
.PHONY: clean
clean:
	rm -rf $(MAKE_PATH)tmp/*
