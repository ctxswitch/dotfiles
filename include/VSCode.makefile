VSCODE_EXTENSIONS ?= bungcip.better-toml eamodio.gitlens \
	golang.go hashicorp.terraform ms-azuretools.vscode-docker \
	ms-python.python ms-python.vscode-pylance ms-vscode.cpptools \
	ms-vsliveshare.vsliveshare rebornix.ruby redhat.vscode-yaml \
	rust-lang.rust sidneys1.gitconfig swashata.beautiful-ui \
	teabyii.ayu vscode-icons-team.vscode-icons wingrunr21.vscode-ruby \
	GitHub.github-vscode-theme msjsdiag.vscode-react-native \
	ms-vscode.vscode-typescript-next 
ifeq ($(OS_NAME), Darwin)
VSCODE_CONFIG_PATH ?= Library/Application Support/Code/User
else
VSCODE_CONFIG_PATH ?= $(HOME)/.config/Code/User
endif

.PHONY: vscode
vscode:
	@for ext in $(VSCODE_EXTENSIONS); do \
		code --install-extension $$ext ;\
	done
	ln -snf $(MAKE_PATH)vscode/settings.json "$(PREFIX)/$(VSCODE_CONFIG_PATH)/settings.json"
	ln -snf $(MAKE_PATH)vscode/keybindings.json "$(PREFIX)/$(VSCODE_CONFIG_PATH)/keybindings.json"
