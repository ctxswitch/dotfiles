RELEASE := $(shell lsb_release -cs)
ALTERNATE_RELEASE ?= cosmic
FONT_PATH := $(PREFIX)/.local/share/fonts
HUGO_PATH := https://github.com/gohugoio/hugo/releases/download/v$(HUGO_VERSION)/hugo_$(HUGO_VERSION)_Linux-64bit.deb
HUGO_FILE := hugo.deb

.PHONY: fonts
fonts:
	mkdir -p $(PREFIX)/.local/share
	ln -snf $(MAKE_PATH)fonts $(FONT_PATH)
	fc-cache

ifdef SUDO_USER
###############################################################################                │  53  endif
### Privileged installs/configs                                                                                     │  54
###############################################################################
.PHONY: configure
configure: configure-wm

.PHONY: configure-wm
configure-wm:
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

.PHONY: install
install: install-packages install-wm install-hugo install-k8s

.PHONY: install-packages
install-packages:
	snap install spotify
	snap install slack --classic
	snap install pencilsheep
	apt -y install zsh vim tmux podman xsel pinentry-tty pinentry-curses \
		pinentry-gnome3 zeal jq git apt-transport-https ca-certificates curl \
		software-properties-common build-essential autoconf bison build-essential \
		libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev \
		libffi-dev libgdbm6 libgdbm-dev python3 python3-pip python3-virtualenv \
		libvirt-clients libvirt-daemon-system libvirt-dev qemu-kvm qemu-utils qemu
	# Still need to install helix for ubuntu
	pip3 install pre-commit
	usermod -a -G kvm $(SUDO_USER)
	usermod -a -G libvirt $(SUDO_USER)

.PHONY: install-wm
install-wm:
	apt -y remove gnome-shell-extension-ubuntu-dock
	apt -y install gnome-session
	apt -y install gnome-tweak-tool
	# Get rid of wayland and go back to xorg due to incompatibilities.
	install -m 0644 $(MAKE_PATH)gnome/custom.conf /etc/gdm3/custom.conf
	ln -snf /usr/share/xsessions/gnome-xorg.desktop /usr/share/xsessions/gnome.desktop

.PHONY: install-hugo ## Install the hugo static site generator
install-hugo:
	curl -LSso $(MAKE_PATH)tmp/$(HUGO_FILE) $(HUGO_PATH)
	apt -y install $(MAKE_PATH)tmp/$(HUGO_FILE)

.PHONY: install-k8s
install-k8s:
	go install sigs.k8s.io/kind@$(KIND_VERSION)
	curl -LSso $(MAKE_PATH)tmp/kubectl $(KUBECTL_URL)
	install $(MAKE_PATH)tmp/kubectl /usr/local/bin/kubectl

###############################################################################                │  53  endif
### Unprivileged installs                                                                                     │  54
###############################################################################
else
.PHONY: configure
	@echo "Nothing to do"

.PHONY: install
	@echo "Nothing to do"
endif # SUDO_USER