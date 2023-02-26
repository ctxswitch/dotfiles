###############################################################################
### Commmon installs and configurations across OSes
###############################################################################
.PHONY: common
common: rust golang lsp zsh tmux git helix kubernetes fonts

###############################################################################
### Install brew and packages
###############################################################################
.PHONY: brew-packages
brew-packages:
	brew install gcc
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

###############################################################################
### Rust
###############################################################################
.PHONY: rust
rust:
	curl https://sh.rustup.rs -sSf | bash -s -- -y --no-modify-path

###############################################################################
### Golang
###############################################################################
.PHONY: golang
golang:
	curl -LSso tmp/golang.tar.gz $(GOLANG_URL)
	rm -rf /tmp/go && mkdir /tmp/go
	sudo tar zxf tmp/golang.tar.gz --strip 1 -C /usr/local/go
	sudo chown -R $(USER):admin /usr/local/go

###############################################################################
### Kubernetes
###############################################################################
.PHONY: kubernetes
kubernetes:
	curl -Lo /tmp/kind $(KIND_URL)
	install -m 0755 -o $(USER) -g admin /tmp/kind /usr/local/bin/kind

###############################################################################
### Language servers
###############################################################################
.PHONY: lsp
lsp:
	npm install -g @ansible/ansible-language-server
	npm install -g yaml-language-server
	npm i -g bash-language-server
	npm i -g vscode-json-languageserver
	/usr/local/go/bin/go install golang.org/x/tools/gopls@latest

###############################################################################
### Zsh configurations
###############################################################################
.PHONY: zsh
zsh:
	ln -snf $(MAKE_PATH)prezto $(PREFIX)/.zprezto
	ln -snf $(MAKE_PATH)prezto/runcoms/zlogout $(PREFIX)/.zlogout
	ln -snf $(MAKE_PATH)prezto/runcoms/zprofile $(PREFIX)/.zprofile
	ln -snf $(MAKE_PATH)prezto/runcoms/zshenv $(PREFIX)/.zshenv
	ln -snf $(MAKE_PATH)zsh/zshrc $(PREFIX)/.zshrc
	ln -snf $(MAKE_PATH)zsh/zlogin $(PREFIX)/.zlogin
	ln -snf $(MAKE_PATH)zsh/zpreztorc $(PREFIX)/.zpreztorc

###############################################################################
### Tmux configurations
###############################################################################
.PHONY: tmux
tmux:
	ln -snf $(MAKE_PATH)tmux $(PREFIX)/.tmux
	ln -snf $(MAKE_PATH)tmux/tmux.conf $(PREFIX)/.tmux.conf

###############################################################################
### Git configurations
###############################################################################
.PHONY: git
git:
	@mkdir -p tmp
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

###############################################################################
### Helix configurations
###############################################################################
.PHONY: helix
helix:
	ln -snf $(MAKE_PATH)helix $(PREFIX)/.config/helix

###############################################################################
### Fonts
###############################################################################
.PHONY: fonts
fonts:
	ln -snfF $(MAKE_PATH)/fonts $(FONT_PATH)
ifeq ($(OS_NAME), Linux)
	fc-cache
endif
