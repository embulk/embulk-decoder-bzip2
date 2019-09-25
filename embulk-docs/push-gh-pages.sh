#!/bin/bash

function re() {
    r "$@"
    if [ $? -ne 0 ];then
        exit $?
    fi
}

function r() {
    echo "$@"
    "$@"
}

[ "$TRAVIS_PULL_REQUEST" != "false" ] && exit 0
[ "$TRAVIS_BRANCH" != "master" -a "$TRAVIS_BRANCH" != "$(git describe --tags --always HEAD)" ] && exit 0

revision="$(git rev-parse HEAD)"
remote="https://github.com/embulk/docs.git"
re ./gradlew site

r git fetch --unshallow || echo "using complete repository."

re rm -rf gh_pages
re git clone . gh_pages
re cd gh_pages

re git remote add travis_push "$remote"
re git fetch travis_push

re git checkout -b gh-pages travis_push/master
re rm -rf docs
re cp -a ../embulk-docs/build/html docs
re git add --all docs

re git config user.name "$GIT_USER_NAME"
re git config user.email "$GIT_USER_EMAIL"
r git commit -m "Updated document $revision"

git show | grep -E '^[+-] ' | grep -Eqv 'Generated by|Generated on|Search.setIndex|meta name="date" content='
if [ $? -ne 0 ];then
    echo "No document changes."
    exit 0
fi

re git config credential.helper "store --file=$HOME/.git_credentials"
echo "https://$GITHUB_TOKEN:@github.com" > "$HOME/.git_credentials"
trap "rm -rf $HOME/.git_credentials" EXIT
re git push travis_push gh-pages:master
