#!/bin/bash

# Install the dependencies
if [[ $(uname -s) == "Linux" ]]
  apt -y install curl git make
else
  xcode-select --install
fi

if [[ ${GIT_METHOD} == "ssh" ]] ; then
  URL="git@github.com:ctxswitch/dotfiles.git"
else
  URL="https://github.com/ctxswitch/dotfiles.git"
fi

# Clone the dotfile
if [[ -d ${PWD}/dotfiles ]] ; then
  git clone ${URL}
fi

# Update the submodules
cd dotfiles
make update
make init
