FONT_PATH := $(PREFIX)/Library/Fonts
HUGO_PATH := https://github.com/gohugoio/hugo/releases/download/v$(HUGO_VERSION)/hugo_$(HUGO_VERSION)_macOS-64bit.tar.gz
HUGO_FILE := hugo.tar.gz

###############################################################################
### Fonts
###############################################################################
.PHONY: fonts
fonts:
	ln -snfF $(MAKE_PATH)/fonts $(FONT_PATH)

ifdef SUDO_USER
###############################################################################
### Privileged installs/configs
###############################################################################
.PHONY: configure
configure:
	@echo "Nothing to configure"

.PHONY: install
install: install-brew install-kind

.PHONY: install-brew
install-brew:
	curl -LSso /tmp/install.sh https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh
	/bin/bash /tmp/install.sh

.PHONY: install-kind
install-kind:
ifeq ($(OS_ARCH), "x86_64")
	curl -Lo /tmp/kind https://kind.sigs.k8s.io/dl/$(KIND_VERSION)/kind-darwin-amd64
else
	curl -Lo /tmp/kind https://kind.sigs.k8s.io/dl/$(KIND_VERSION)/kind-darwin-arm64
endif
	chmod +x /tmp/kind
	mv /tmp/kind $(PREFIX)/bin/kind

###############################################################################
### Unprivileged installs/configs
###############################################################################
else
.PHONY: configure
	@echo "Nothing to configure"

.PHONY: install
install: install-packages install-hugo

.PHONY: install-packages
install-packages:
	brew install python3
	brew install git
	brew install jq
	brew install bash
	brew install npm
	brew install podman
	brew install helix
	brew install protobuf
	brew install grpc
	brew install grpcurl
	brew install hugo
endif
