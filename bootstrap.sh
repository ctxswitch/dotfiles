#!/bin/bash

# Install the dependencies
apt -y install curl git make

if [[ ${GIT_METHOD} == "ssh" ]] ; then
  URL="git@github.com:ctxswitch/dotfiles.git"
else
  URL="https://github.com/ctxswitch/dotfiles.git"
fi

# Clone the dotfile
if [[ -d ${PWD}/dotfiles ]] ; then
  git clone ${URL}
fi

# Update the submodules and pathogen
cd dotfiles
make update
