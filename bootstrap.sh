#!/bin/bash
set -e
if [ -f ~/.bootstrap ] ; then
	source ~/.bootstrap
fi

PREFIX=${HOME}
SCRIPT_PATH=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

GOLANG_VERSION=${GOLANG_VERSION:-1.21.0}
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
	VSCODE_CONFIG_PATH="${PREFIX}/Library/Application Support/Code/User"
	NVIM_CONFIG_PATH=${PREFIX}/.config/nvim
else
	FONT_PATH=${PREFIX}/.local/share/fonts
	ADMIN_GROUP=adm
	HOMEBREW_PATH=/home/linuxbrew/.linuxbrew
	VSCODE_CONFIG_PATH="${PREFIX}/.config/Code/User"
	# TODO: set up nvim paths for linux
fi

CARGO_PATH=${PREFIX}/.cargo

GOLANG_URL="https://go.dev/dl/go${GOLANG_VERSION}.${OS_NAME_LOWER}-${OS_ARCH}.tar.gz"
KUBECTL_URL="https://storage.googleapis.com/kubernetes-release/release/${KUBERNETES_RELEASE}/bin/${OS_NAME_LOWER}/${OS_ARCH}/kubectl"
KIND_URL="https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-${OS_NAME_LOWER}-${OS_ARCH}"

VSCODE_EXTENSIONS="bungcip.better-toml eamodio.gitlens
golang.go hashicorp.terraform ms-azuretools.vscode-docker
ms-python.python ms-python.vscode-pylance ms-vscode.cpptools
ms-vsliveshare.vsliveshare rebornix.ruby redhat.vscode-yaml
rust-lang.rust sidneys1.gitconfig swashata.beautiful-ui
teabyii.ayu vscode-icons-team.vscode-icons wingrunr21.vscode-ruby
GitHub.github-vscode-theme msjsdiag.vscode-react-native
ms-vscode.vscode-typescript-next"

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
	echo "  Golang:     ${GOLANG_VERSION}"
	echo "  Hugo:       ${HUGO_VERSION}"
	echo "  Fex:        ${FEX_VERSION}"
	echo "  Kubernetes: ${KUBERNETES_RELEASE}"
	echo "  Kind:       ${KIND_VERSION}"
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

function update-submodules() {
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
	brew install jq
	brew install bash
	brew install npm
	brew install protobuf
	brew install grpc
	brew install grpcurl
	brew install hugo
	brew install neovim
	brew install tmux
	brew install fzf
	brew install fd
	brew install ripgrep

	brew tap homebrew/cask-fonts
	brew install --cask font-victor-mono-nerd-font
	brew install --cask font-inconsolata-nerd-font
	brew install --cask font-inconsolata-go-nerd-font
  	brew install --cask font-jetbrains-mono-nerd-font
  	brew install --cask font-iosevka-nerd-font
  	brew install --cask font-iosevka-term-font
  	brew install --cask font-iosevka-term-nerd-font
}

function install_rust() {
	curl https://sh.rustup.rs -sSf | bash -s -- -y --no-modify-path
}

function install_golang() {
	do_sudo
	curl -LSso /tmp/golang.tar.gz ${GOLANG_URL}
	# TODO: only install if the version does not match
	sudo rm -rf /usr/local/go/*
	sudo mkdir -p /usr/local/go
	sudo tar zxf /tmp/golang.tar.gz --strip 1 -C /usr/local/go
	sudo chown -R ${USER}:${ADMIN_GROUP} /usr/local/go
}

function install_kubernetes() {
	do_sudo
	curl -Lo /tmp/kind ${KIND_URL}
	sudo install -m 0755 -o ${USER} -g ${ADMIN_GROUP} /tmp/kind /usr/local/bin/kind
}

function install_all() {
	install_rust
	install_golang
	install_homebrew_packages
	install_kubernetes
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

	# Git configuration
	awk \
		-v name="${GIT_USER_NAME}" \
		-v email="${GIT_USER_EMAIL}" \
		-v key="${GIT_USER_SIGNING_KEY}" \
		-v github="${GITHUB_USER}" \
		'{ \
		gsub("##GIT_USER_NAME##",name); \
		gsub("##GIT_USER_EMAIL##",email); \
		gsub("##GIT_USER_SIGNING_KEY##",key); \
		gsub("##GITHUB_USER##",github); \
		print \
  		}' git/.gitconfig > /tmp/gitconfig
  	install /tmp/gitconfig ${PREFIX}/.gitconfig

	# Neovim
	if ! [ -d ${PREFIX}/.local/share/nvim/site/pack/packer/start/packer.nvim ] ; then
		git clone --depth 1 https://github.com/wbthomason/packer.nvim ${PREFIX}/.local/share/nvim/site/pack/packer/start/packer.nvim
	fi
	ln -snf ${SCRIPT_PATH}/nvim/config ${NVIM_CONFIG_PATH}
	# TODO: Expect errors here because nvim will try to load all of the non-existent plugins.  I need to go back
	# through and do a seperate bootstrap before the configs are linked.
	nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'

	# Fonts
	ln -snf ${SCRIPT_PATH}/fonts ${FONT_PATH}

	# Linux specific configurations.  Revisit this
	if [[ $OS_DIST == "Linux" ]] ; then
		fc-cache
		gsettings set org.gnome.desktop.interface gtk-theme Yaru-dark
		gsettings set org.gnome.desktop.interface monospace-font-name 'Iosevka 13'
		gsettings set org.gnome.desktop.peripherals.touchpad click-method fingers
		gsettings set org.gnome.desktop.background show-desktop-icons false
		gsettings set org.gnome.shell.extensions.ding show-home false
		gsettings set org.gnome.desktop.wm.keybindings switch-windows-backward "['<Alt><Super>j']"
		gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-up "['<Primary><Alt>l']"
		gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-down "['<Primary><Alt>k']"
		gsettings set org.gnome.desktop.wm.keybindings switch-windows "['<Alt><Super>;']"
		${SCRIPT_PATH}/gnome/jellybeans-term.sh
  	fi

	# fzf configuration
	$(brew --prefix)/opt/fzf/install --no-update-rc --key-bindings --completion
}

function vscode() {
	for ext in $VSCODE_EXTENSIONS; do \
		code --install-extension $ext ;\
	done
		ln -snf ${SCRIPT_PATH}/vscode/settings.json "${VSCODE_CONFIG_PATH}/settings.json"
		ln -snf ${SCRIPT_PATH}/vscode/keybindings.json "${VSCODE_CONFIG_PATH}/keybindings.json"
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
		"go" | "golang" | "install-golang")
			echo "Installing golang $GOLANG_VERSION..."
			install_golang
			;;
		"rust" | "install-rust")
			echo "Installing rust..."
			install_rust
			;;
		"brew" | "install-homebrew")
			echo "Installing homebrew packages..."
			install_homebrew_packages
			;;
		"k8s" | "install-k8s" | "install-kubernetes")
			echo "Installing kubernetes tools..."
			install_kubernetes
			;;
		"vscode")
			echo "Installing extensions and configuring..."
			vscode
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
			vscode
			;;
	esac
