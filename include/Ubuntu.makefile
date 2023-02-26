###############################################################################
### OS specific installs
###############################################################################
.PHONY: install
install:
	@echo "Nothing to install"

###############################################################################
### OS specific configurations
###############################################################################
.PHONY: configure
configure:
	gsettings set org.gnome.desktop.interface gtk-theme Yaru-dark
	gsettings set org.gnome.desktop.interface monospace-font-name 'Iosevka 13'
	gsettings set org.gnome.desktop.peripherals.touchpad click-method fingers
	gsettings set org.gnome.desktop.background show-desktop-icons false
	gsettings set org.gnome.shell.extensions.ding show-home false
	gsettings set org.gnome.desktop.wm.keybindings switch-windows-backward "['<Alt><Super>j']"
	gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-up "['<Primary><Alt>l']"
	gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-down "['<Primary><Alt>k']"
	gsettings set org.gnome.desktop.wm.keybindings switch-windows "['<Alt><Super>;']"
	$(MAKE_PATH)gnome/jellybeans-term.sh

###############################################################################
### Distclean
###############################################################################
.PHONY: distclean
distclean:
	brew remove --force $(shell brew list --formula)
	brew remove --cask --force $(shell brew list)
