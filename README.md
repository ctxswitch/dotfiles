# Dotfiles

## Installation

* Install applications and dependencies. When running on Linux, log out and then log back in again to pick up new session settings and group configurations.

```sh
$ git clone https://github.com/ctxswitch/dotfiles.git
$ cd dotfiles
$ make update
$ sudo make
```


* Import the gpg key and get the identifier for the signing key

```
gpg --import /path/to/signing-key.asc
gpg --list-secret-keys --keyid-format LONG
```

* Set up some local environment variables to customize the install.  At a minimum create a `.local` file in the dotfiles directory and include your git config information:

```
GIT_USER_NAME="Rob Lyon"
GIT_USER_EMAIL="rob@ctxswitch.com"
GIT_USER_SIGNING_KEY="F0E2C3B4E2BF179D"
```

* Set up your personal environement.  This will set up zsh, git, prezto, tmux, etc.

```sh
$ make
```

