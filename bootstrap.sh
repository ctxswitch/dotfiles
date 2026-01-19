#!/bin/bash
set -e
if [ -f ~/.bootstrap ] ; then
	source ~/.bootstrap
fi

PREFIX=${HOME}
SCRIPT_PATH=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

HUGO_VERSION=${HUGO_VERSION:-0.110.0}
FEX_VERSION=${FEX_VERSION:-2.0.0}
KUBERNETES_RELEASE=${KUBERNETES_VERSION:-$(curl -L -s https://dl.k8s.io/release/stable.txt)}
KIND_VERSION=${KIND_VERSION:-v0.17.0}
IOSEVKA_VERSION=${IOSEVKA_VERSION:-19.0.1}

GIT_USER_NAME=${GIT_USER_NAME:-"Anonymous"}
GIT_USER_EMAIL=${GIT_USER_EMAIL:-"anonymous@gmail.com"}
GIT_USER_SIGNING_KEY=${GIT_USER_SIGNING_KEY:-"A1E2B3BFE2AF174D"}
GIT_METHOD="https"
GITHUB_USER=${GITHUB_USER:-"ctxswitch"}

OS_NAME=$(uname -s)
OS_NAME_LOWER=$(echo $OS_NAME | tr A-Z a-z)
OS_DIST=$(uname)
OS_MACHINE=$(uname -m)

if [[ "$OS_MACHINE" == "x86_64" ]] ; then
	OS_ARCH="amd64"
else
	OS_ARCH="$OS_MACHINE"
fi

if [[ "$OS_NAME" == "Darwin" ]] ; then
	FONT_PATH=${PREFIX}/Library/Fonts
	ADMIN_GROUP=admin
	HOMEBREW_PATH=/opt/homebrew
else
	FONT_PATH=${PREFIX}/.local/share/fonts
	ADMIN_GROUP=adm
	HOMEBREW_PATH=/home/linuxbrew/.linuxbrew
	# TODO: set up nvim paths for linux
fi

CARGO_PATH=${PREFIX}/.cargo

KUBECTL_URL="https://storage.googleapis.com/kubernetes-release/release/${KUBERNETES_RELEASE}/bin/${OS_NAME_LOWER}/${OS_ARCH}/kubectl"
KIND_URL="https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-${OS_NAME_LOWER}-${OS_ARCH}"

export PREFIX SCRIPT_PATH GOLANG_VERSION HUGO_VERSION FEX_VERSION KUBERNETES_RELEASE \
	KIND_VERSION GIT_USER_NAME GIT_USER_EMAIL GIT_USER_SIGNING_KEY \
	OS_NAME OS_NAME_LOWER OS_DIST OS_MACHINE OS_ARCH FONT_PATH ADMIN_GROUP HOMEBREW_PATH \
	CARGO_PATH GOLANG_URL KUBECTL_URL KIND_URL NVIM_CONFIG_PATH

export PATH=/usr/local/go/bin:$CARGO_PATH/bin:$HOMEBREW_PATH/bin:$PATH

function help() {
	echo "Bootstraps a workstation."
	echo
	echo "Environment:"
	echo "  Prefix:          $PREFIX"
	echo "  User:            $USER"
	echo "  Admin Group:     $ADMIN_GROUP"
	echo "  OS name:         $OS_NAME"
	echo "  OS name (lower): $OS_NAME_LOWER"
	echo "  OS Dist:         $OS_DIST"
	echo "  Machine:         $OS_MACHINE"
	echo "  Arch:            $OS_ARCH"
	echo "  Script Path:     $SCRIPT_PATH"
	echo "  Homebrew Path:   $HOMEBREW_PATH"
	echo "  Cargo Path:      $CARGO_PATH"
	echo "  VSCode Path:     $VSCODE_PATH"
	echo
	echo "Versions:"
	echo "  Hugo:       ${HUGO_VERSION}"
	echo "  Fex:        ${FEX_VERSION}"
	echo "  Iosevka:    ${IOSEVKA_VERSION}"
	echo
	echo "Git Configuration:"
	echo "  Username:    $GIT_USER_NAME"
	echo "  Email:       $GIT_USER_EMAIL"
	echo "  Signing Key: $GIT_USER_SIGNING_KEY"
	echo "  Github User: $GITHUB_USER"
	echo
}

function initialize() {
	do_sudo
	# Install the dependencies
	if [[ "${OS_DIST}" == "Linux" ]] ; then
		sudo apt -y install git build-essential zsh pinentry-tty pinentry-curses pinentry-gnome3 curl
	else
		xcode-select --install || true
	fi

	echo "Installing Homebrew"
	curl -LSso /tmp/install.sh https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh
	/bin/bash /tmp/install.sh
	eval_homebrew
	install_homebrew_packages

	if [[ ${GIT_METHOD} == "ssh" ]] ; then
		URL="git@github.com:ctxswitch/dotfiles.git"
	else
		URL="https://github.com/ctxswitch/dotfiles.git"
	fi

	# Clone the dotfile
	if [[ -d ${PWD}/dotfiles ]] ; then
		git clone ${URL}
	fi  
}

function update_submodules() {
	git submodule update --init --recursive
}

function eval_homebrew() {
	if [ -d $HOMEBREW_PATH ]; then
		eval "$($HOMEBREW_PATH/bin/brew shellenv)"
	else
		echo "Could not load homebrew environment.  Please check the install."
		exit 1
	fi
}

function install_homebrew_packages() {
	eval_homebrew
	brew install gcc
	brew install python3
	brew install git
	brew install git-town
	brew install jq
	brew install bash
	brew install npm
	brew install protobuf
	brew install grpc
	brew install grpcurl
	brew install hugo
	brew install tmux
	brew install fzf
	brew install fd
	brew install ripgrep
	brew install gnupg gpg-agent pinentry-mac
	
	brew install kubectl
	brew install k3d
	brew install kustomize
	brew install kubectx

	brew install go@1.24

	brew tap homebrew/cask-fonts
	brew install --cask font-victor-mono-nerd-font
	brew install --cask font-inconsolata-nerd-font
	brew install --cask font-inconsolata-go-nerd-font
  	brew install --cask font-jetbrains-mono-nerd-font
  	brew install --cask font-iosevka-nerd-font
  	brew install --cask font-iosevka-term-font
  	brew install --cask font-iosevka-term-nerd-font
	brew install --cask ghostty
}

function install_lsp() {
  do_sudo
  eval_homebrew
  npm i -g @ansible/ansible-language-server
	npm i -g yaml-language-server
	npm i -g bash-language-server
	npm i -g vscode-langservers-extracted
	npm i -g typescript typescript-language-server
	npm i -g vls
	npm i -g dockerfile-language-server-nodejs
	brew install marksman
	brew install llvm
	go install golang.org/x/tools/gopls@latest
}

function install_rust() {
	curl https://sh.rustup.rs -sSf | bash -s -- -y --no-modify-path
}

function install_all() {
	install_rust
	install_homebrew_packages
}

function configure_all() {
	# ZSH configs
	ln -snf ${SCRIPT_PATH}/prezto ${PREFIX}/.zprezto
	ln -snf ${SCRIPT_PATH}/prezto/runcoms/zlogout ${PREFIX}/.zlogout
	ln -snf ${SCRIPT_PATH}/prezto/runcoms/zprofile ${PREFIX}/.zprofile
	ln -snf ${SCRIPT_PATH}/prezto/runcoms/zshenv ${PREFIX}/.zshenv
	ln -snf ${SCRIPT_PATH}/zsh/zshrc ${PREFIX}/.zshrc
	ln -snf ${SCRIPT_PATH}/zsh/zlogin ${PREFIX}/.zlogin
	ln -snf ${SCRIPT_PATH}/zsh/zpreztorc ${PREFIX}/.zpreztorc

	# Tmux configs
	ln -snf ${SCRIPT_PATH}/tmux ${PREFIX}/.tmux
	ln -snf ${SCRIPT_PATH}/tmux/tmux.conf ${PREFIX}/.tmux.conf

	# Ghostty
	ln -snf ${SCRIPT_PATH}/ghostty ${PREFIX}/.config/ghostty

	# Helix
	ln -snf ${SCRIPT_PATH}/helix ${PREFIX}/.config/helix

	# Git configuration
	awk \
		-v name="${GIT_USER_NAME}" \
		-v email="${GIT_USER_EMAIL}" \
		-v key="${GIT_USER_SIGNING_KEY}" \
		-v github="${GITHUB_USER}" \
		'{ \
		gsub("##GIT_USER_NAME##",name); \
		gsub("##GIT_USER_EMAIL##",email); \
		gsub("##GIT_USER_SIGNINGKEY##",key); \
		gsub("##GITHUB_USER##",github); \
		print \
  		}' git/.gitconfig > /tmp/gitconfig
  	install /tmp/gitconfig ${PREFIX}/.gitconfig

	# Fonts
	ln -snf ${SCRIPT_PATH}/fonts ${FONT_PATH}

	# fzf configuration
	$(brew --prefix)/opt/fzf/install --no-update-rc --key-bindings --completion
}

function do_sudo() {
	# Get a password for sudo so we don't need to reenter it
	# later on.
	sudo echo 0 > /dev/null
}

case $1 in
	"configure")
		echo "Configuring all applications..."
		configure_all
		;;
	"update-submodules")
		echo "Updating submodules"
		update_submodules
		;;
	"update")
		echo "Updating all submodules and fonts..."
		update_submodules
		;;
	"install")
		echo "Installing dev environment..."
		do_sudo
		install_all
		;;
	"lsp")
		echo "Installing lsp"
		install_lsp
		;;
	"rust" | "install-rust")
		echo "Installing rust..."
		install_rust
		;;
	"brew" | "install-homebrew")
		echo "Installing homebrew packages..."
		install_homebrew_packages
		;;
	"init" | "initialize")
		echo "Initializing..."
		initialize
		;;
	"help" | "-h" | "--help")
		help
		;;
	*)
		do_sudo
		install_all
		configure_all
		;;
esac
