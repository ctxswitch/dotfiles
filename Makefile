.DEFAULT_GOAL := all

PREFIX := $(HOME)
MAKE_PATH := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))
SHELL := /bin/bash

GOLANG_VERSION ?= 1.20.1
HUGO_VERSION ?= 0.110.0
FEX_VERSION ?= 2.0.0
KUBERNETES_RELEASE ?= $(shell curl -L -s https://dl.k8s.io/release/stable.txt)
KIND_VERSION ?= v0.17.0
IOSEVKA_VERSION ?= 19.0.1

GIT_USER_NAME ?= Anonymous
GIT_USER_EMAIL ?= anonymous@gmail.com
GIT_USER_SIGNINGKEY ?= A1E2B3BFE2AF174D

OS_NAME := $(shell uname -s)
OS_NAME_LOWER := $(shell echo $(OS_NAME) | tr A-Z a-z)
OS_DIST ?= $(shell uname)
OS_MACHINE ?= $(shell uname -m)
$(info OS_MACHINE = '$(OS_MACHINE)')
ifeq ($(OS_MACHINE), x86_64)
OS_ARCH := amd64
else
OS_ARCH := $(OS_MACHINE)
endif
$(info OS_ARCH = '$(OS_ARCH)')

ifeq ($(OS_NAME), Darwin)
FONT_PATH := $(PREFIX)/Library/Fonts
ADMIN_GROUP := admin
HOMEBREW_PATH := /opt/homebrew
else
FONT_PATH := $(PREFIX)/.local/share/fonts
ADMIN_GROUP := adm
HOMEBREW_PATH := /home/linuxbrew/.linuxbrew
endif

CARGO_PATH := $(PREFIX)/.cargo

GOLANG_URL ?= https://go.dev/dl/go$(GOLANG_VERSION).$(OS_NAME_LOWER)-$(OS_ARCH).tar.gz
KUBECTL_URL ?= https://storage.googleapis.com/kubernetes-release/release/$(KUBERNETES_RELEASE)/bin/$(OS_NAME_LOWER)/$(OS_ARCH)/kubectl
KIND_URL ?= https://kind.sigs.k8s.io/dl/$(KIND_VERSION)/kind-$(OS_NAME_LOWER)-$(OS_ARCH)
IOSEVKA_URL ?= https://github.com/be5invis/Iosevka/releases/download/v$(IOSEVKA_VERSION)/ttf-iosevka-$(IOSEVKA_VERSION).zip

include $(MAKE_PATH).local
include include/Common.makefile
include include/VSCode.makefile

ifeq ($(OS_NAME), Darwin)
include include/MacOS.makefile
else
include include/Ubuntu.makefile
endif

all: sudo common install configure

###############################################################################
### Get sudo password before we clutter the screen
###############################################################################
.PHONY: sudo
sudo:
	# Prompt for sudo
	$(shell sudo echo 0 > /dev/null)

###############################################################################
### Initialize
###############################################################################
.PHONY: init
init: update-submodules
	curl -LSso /tmp/install.sh https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh
	/bin/bash /tmp/install.sh
ifeq ($(OS_NAME), Linux)
	sudo apt -y install git build-essential zsh pinentry-tty pinentry-curses pinentry-gnome3 curl
	sudo apt -y remove gnome-shell-extension-ubuntu-dock
	# sudo apt -y install gnome-session
	# sudo apt -y install gnome-tweaks
	# Get rid of wayland and go back to xorg due to incompatibilities.
	sudo install -m 0644 $(MAKE_PATH)gnome/custom.conf /etc/gdm3/custom.conf
	sudo ln -snf /usr/share/xsessions/gnome-xorg.desktop /usr/share/xsessions/gnome.desktop
endif

###############################################################################
### Update
###############################################################################
.PHONY: update ## Run all update targets
update: update-submodules update-fonts

.PHONY: update-submodules ## Update all the submodules
update-submodules:
	git submodule update --init --recursive

.PHONY: update-fonts ## Update custom fonts
update-fonts:
	rm -rf /tmp/iosevka
	mkdir /tmp/iosevka
	curl -LSso /tmp/iosevka.zip $(IOSEVKA_URL)
	unzip /tmp/iosevka.zip -d /tmp/iosevka
	rsync -av --delete /tmp/iosevka/* $(MAKE_PATH)/fonts

###############################################################################
### Clean
###############################################################################
.PHONY: clean # Clean up any temporary files
clean:
	rm -rf tmp/*
