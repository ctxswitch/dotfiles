PREFIX := $(HOME)
MAKE_PATH := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))
SHELL := /bin/bash

include $(MAKE_PATH).local

OS_NAME := $(shell uname -s)
OS_NAME_LOWER := $(shell echo $(OS_NAME) | tr A-Z a-z)
OS_DIST ?= $(shell uname)
OS_ARCH ?= $(shell uname -m)

KUBERNETES_RELEASE ?= $(shell curl -L -s https://dl.k8s.io/release/stable.txt)
KUBECTL_URL ?= https://storage.googleapis.com/kubernetes-release/release/$(KUBERNETES_RELEASE)/bin/$(OS_NAME_LOWER)/amd64/kubectl
KIND_VERSION ?= v0.17.0

GOLANG_VERSION ?= 1.19.6
HUGO_VERSION ?= 0.55.6
FEX_VERSION ?= 2.0.0

GIT_USER_NAME ?= Anonymous
GIT_USER_EMAIL ?= anonymous@gmail.com
GIT_USER_SIGNINGKEY ?= A1E2B3BFE2AF174D

IOSEVKA_VERSION ?= 19.0.1
IOSEVKA_PATH := https://github.com/be5invis/Iosevka/releases/download/v$(IOSEVKA_VERSION)/ttc-iosevka-$(IOSEVKA_VERSION).zip

include include/Common.makefile

ifeq ($(OS_NAME), Darwin)
include include/MacOS.makefile
else
include include/Ubuntu.makefile
endif

all: install configure common

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
	curl -LSso /tmp/iosevka.zip $(IOSEVKA_PATH)
	unzip /tmp/iosevka.zip -d /tmp/iosevka
	rsync -av --delete /tmp/iosevka/* $(MAKE_PATH)/fonts

###############################################################################
### Clean
###############################################################################
.PHONY: clean # Clean up any temporary files
clean:
	rm -rf tmp/*
