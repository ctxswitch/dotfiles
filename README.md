# Enterprise Dotfiles

#### Because anything labeled as "Enterprise" is bloated far beyond it's original intent.

What started out as simple dotfiles has turned into something quite a bit larger.  I've merged in many package installations and base configurations to set the baseline on new installs of my personal workstations.  Currently there are two seperate modes of executing the targets.  If you run `make` with sudo, it will run through application installs and some global configurations.  If you run `make` as your user, your personnal environment is set up.

## Dependencies

* Curl
* Make
* Git

## Installation

### Global installation and configuation

Install the dependencies, clone the repo, and run the following commands to install applications and perform global configurations:

```sh
$ git clone https://github.com/ctxswitch/dotfiles.git
$ cd dotfiles
$ make update
$ sudo make
```

Log out and then log back in again to pick up new session and group configurations.

### Create or import your signing key

You'll need to either create or import a git signing key to add it to the local configuration.  To create a key run:

```
$ gpg --full-generate-key
gpg (GnuPG) 2.2.12; Copyright (C) 2018 Free Software Foundation, Inc.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Please select what kind of key you want:
   (1) RSA and RSA (default)
   (2) DSA and Elgamal
   (3) DSA (sign only)
   (4) RSA (sign only)
Your selection? 1
RSA keys may be between 1024 and 4096 bits long.
What keysize do you want? (3072) 4096
Key is valid for? (0) 1y
Is this correct? (y/N) y
Change (N)ame, (C)omment, (E)mail or (O)kay/(Q)uit? O
...
public and secret key created and signed.                                                     
```

To import a key:

```
gpg --import /path/to/signing-key.asc
```

Then grab the id for the next section.

```
$ gpg --list-secret-keys --keyid-format LONG
gpg: checking the trustdb
gpg: marginals needed: 3  completes needed: 1  trust model: pgp
gpg: depth: 0  valid:   1  signed:   0  trust: 0-, 0q, 0n, 0m, 0f, 1u
gpg: next trustdb check due at 2022-05-18
/home/rlyon/.gnupg/pubring.kbx
------------------------------
sec   rsa4096/F0E2C3B4E2BF179D XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
uid                 [ultimate] Rob Lyon (Github signing key) <rob@ctxswitch.com>
ssb   rsa4096/XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

### Add the local configuration file

Set up some local environment variables to customize the install.  At a minimum create a `.local` file in the dotfiles directory and include your git config information:

```
GIT_USER_NAME="Rob Lyon"
GIT_USER_EMAIL="rob@ctxswitch.com"
GIT_USER_SIGNING_KEY="F0E2C3B4E2BF179D"
```

### Set up your personal environement

```sh
$ make
```

## Notes:

* There is a bootstrap script available that ensure the appropriate dependencies are installed.  There's not much to it and it will only work on Debian variants.  To run it execute the following command:

```
curl https://raw.githubusercontent.com/ctxswitch/dotfiles/master/bootstrap.sh | sudo bash
```
