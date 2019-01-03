#!/bin/bash

# Install the dependencies
apt install vim curl git zsh make

# Clone the dotfile
if [[ -d ${PWD}/dotfiles ]] ; then
  git clone https://github.com/rlyon/dotfiles.git
fi

# Update the submodules and pathogen
cd dotfiles
make update
