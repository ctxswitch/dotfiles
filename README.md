# Dotfiles

What started out as simple dotfiles has turned into something quite a bit larger.  I've merged in many package installations and base configurations to set the baseline on new installs.  Currently there are two seperate modes of executing the targets.  If you run `make` with sudo, it will run through application installs and some global configurations.  If you run `make` as your user, your personnal environment is set up.

## Dependencies

* Curl
* Make
* Git

## Installation

Install the dependencies, clone the repo, and run the following commands to install applications and perform global configurations:

```sh
$ git clone https://github.com/ctxswitch/dotfiles.git
$ cd dotfiles
$ make update
$ sudo make
```

Log out and then log back in again to pick up new session and group configurations then run the following to set up your environment:

```sh
$ make
```

There is a bootstrap script available that ensure the appropriate dependencies are installed.  There's not much to it and it will only work on Debian variants.  To run it execute the following command:

```
curl https://raw.githubusercontent.com/ctxswitch/dotfiles/master/bootstrap.sh | sudo bash
```

## Targets

The Makefile is broken up into 6 meta-targets:
* `fonts` - Installs the iosevka fonts.
* `terminal` - Installs and configures zsh and pretzo.
* `packages` - Installs general packages with snap and apt.
* `gnome` - Removes the ubuntu styled desktop and customized gnome settings.
* `devtools` - Development and infrastructure tools.
* `languages` - Set up a variety of development languages.