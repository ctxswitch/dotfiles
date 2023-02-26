# Dotfiles

## Installation

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/ctxswitch/dotfiles/HEAD/bootstrap.sh)"
```

* Import your gpg key and get the identifier for the signing key

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

* Install and configure

```sh
$ make
```
