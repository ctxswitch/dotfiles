#!/bin/bash

add_uuid() {
    UUID=$1

    LIST="$(
        {
            dconf read /org/gnome/terminal/legacy/profiles:/list | tr -d '[]' | tr , "\n" | fgrep -v "$UUID"
            echo "'$UUID'"
        } | head -c-1 | tr "\n" ,
    )"

    dconf write /org/gnome/terminal/legacy/profiles:/list "[$LIST]"
}

function get_uuid() {
  J=$1
  PROFILES=$(dconf read /org/gnome/terminal/legacy/profiles:/list | \
    tr "'" '"' | \
    jq -r '.[]')

  while read PROFILE; do
    eval NAME=$(dconf read /org/gnome/terminal/legacy/profiles:/:$PROFILE/visible-name)
    if [ "${NAME}" == "${J}" ] ; then
      echo $PROFILE
      return
    fi
  done <<< $PROFILES
  echo $(uuidgen)
}

UUID=$(get_uuid "Jellybeans")

cat > /tmp/jellybeans.ini <<'EOF'
[/]
foreground-color='#adadad'
visible-name='Jellybeans'
default-size-columns=100
default-size-rows=28
palette=['#3b3b3b', '#cf6a4c', '#99ad6a', '#d8ad4c', '#597bc5', '#a037b0', '#71b9f8', '#adadad', '#636363', '#f79274', '#c1d592', '#ffd574', '#81a3ed', '#c85fd8', '#99e1ff', '#d5d5d5']
bold-is-bright=false
use-system-font=false
use-theme-colors=false
font='Iosevka 12'
use-theme-transparency=false
use-theme-background=false
bold-color-same-as-fg=true
bold-color='#adadad'
background-color='#151515'
audible-bell=false
scrollbar-policy='never'
EOF

echo "Adding jellybeans theme: $UUID"
dconf load /org/gnome/terminal/legacy/profiles:/:$UUID/ < /tmp/jellybeans.ini
add_uuid $UUID
