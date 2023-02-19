ifdef SUDO_USER
.PHONY: common
common: install-rust install-golang

.PHONY: install-rust ## Install the Rust programming language
install-rust:
	curl https://sh.rustup.rs -sSf | bash -s -- -y --no-modify-path

.PHONY: install-golang ## Install the Go programming language
install-golang:
	curl -LSso tmp/golang.tar.gz https://dl.google.com/go/go$(GOLANG_VERSION).$(OS_NAME_LOWER)-$(OS_ARCH).tar.gz
	mkdir -p /usr/local/go
	tar zxf tmp/golang.tar.gz --strip 1 -C /usr/local/go

else
.PHONY: common
common: install-lsp zsh tmux git helix

.PHONY: install-lsp
install-lsp:
	npm install -g @ansible/ansible-language-server
	npm install -g yaml-language-server
	npm i -g bash-language-server
	npm i -g vscode-json-languageserver
	go install golang.org/x/tools/gopls@latest

.PHONY: zsh
zsh:
	ln -snf $(MAKE_PATH)prezto $(PREFIX)/.zprezto
	ln -snf $(MAKE_PATH)prezto/runcoms/zlogout $(PREFIX)/.zlogout
	ln -snf $(MAKE_PATH)prezto/runcoms/zprofile $(PREFIX)/.zprofile
	ln -snf $(MAKE_PATH)prezto/runcoms/zshenv $(PREFIX)/.zshenv
	ln -snf $(MAKE_PATH)zsh/zshrc $(PREFIX)/.zshrc
	ln -snf $(MAKE_PATH)zsh/zlogin $(PREFIX)/.zlogin
	ln -snf $(MAKE_PATH)zsh/zpreztorc $(PREFIX)/.zpreztorc

.PHONY: tmux
tmux:
	ln -snf $(MAKE_PATH)tmux $(PREFIX)/.tmux
	ln -snf $(MAKE_PATH)tmux/tmux.conf $(PREFIX)/.tmux.conf

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

.PHONY: helix
helix:
	ln -snf $(MAKE_PATH)helix $(PREFIX)/.config/helix
endif
