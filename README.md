# Dotfiles

Set up vim, prezto, powerline fonts.

## Dependencies

* Curl
* ZSH
* Vim
* Make
* Git

## Installation

Install the dependencies, clone the repo, and run:

```
# make update
# make install
```

There is a bootstrap script available that ensure the appropriate dependencies are installed.  There's not much to it and it will only work on Debian variants.  To run it execute the following command:

```
curl https://raw.githubusercontent.com/rlyon/dotfiles/master/bootstrap.sh | sudo bash
```
