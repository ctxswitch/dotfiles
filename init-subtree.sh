#!/bin/bash

PREFIX=${1:-/tmp}
REPO=$2
BRANCH=$3

USER=$(awk -F/ '{print $(NF-1)}' <<< $REPO | tr A-Z a-z)
PROJECT=$(awk -F/ '{print $(NF)}' <<< $REPO | tr A-Z a-z | cut -d. -f1)
NAME=${USER}@${PROJECT}

echo "Working on $NAME: ($REPO)"

git remote | grep $NAME 2>&1 >/dev/null
if [[ $? -ne 0 ]] ; then
    git remote add $NAME https://$REPO
    git subtree add --squash --prefix=${PREFIX}/${PROJECT} ${NAME} ${BRANCH}
fi
