#!/bin/bash

# Install the dependencies
apt -y install vim curl git zsh make jq

# Clone the dotfile
if [[ -d ${PWD}/dotfiles ]] ; then
  git clone https://github.com/ctxswitch/dotfiles.git
fi

# Update the submodules and pathogen
cd dotfiles
make update
