#!/bin/bash

VERSION=""

# get parameters
while getopts v: flag
do
    case "${flag}" in
        v) VERSION=${OPTARG};;
    esac
done

# fetch latest changes and prune deleted branches
git fetch --prune --unshallow 2>/dev/null

# get the latest tag or default to v0.1.0 if no tags exist
CURRENT_VERSION=$(git describe --abbrev=0 --tags 2>/dev/null)
if [[ -z $CURRENT_VERSION ]]; then
    CURRENT_VERSION="v0.1.0"
fi
echo "Current Version: $CURRENT_VERSION"

# parse current version parts
CURRENT_VERSION_PARTS=(${CURRENT_VERSION//./ })
VNUM1=${CURRENT_VERSION_PARTS[0]//v/}  # remove 'v' from version
VNUM2=${CURRENT_VERSION_PARTS[1]}
VNUM3=${CURRENT_VERSION_PARTS[2]}

# increment version based on input parameter
if [[ $VERSION == 'major' ]]; then
    VNUM1=$((VNUM1 + 1))
    VNUM2=0
    VNUM3=0
elif [[ $VERSION == 'minor' ]]; then
    VNUM2=$((VNUM2 + 1))
    VNUM3=0
elif [[ $VERSION == 'patch' ]]; then
    VNUM3=$((VNUM3 + 1))
else
    echo "No version type or incorrect type specified. Please specify major, minor, or patch"
    exit 1
fi

# create new tag
NEW_TAG="v$VNUM1.$VNUM2.$VNUM3"
echo "($VERSION) Updating $CURRENT_VERSION to $NEW_TAG"

# get current commit hash and check if it already has a tag
GIT_COMMIT=$(git rev-parse HEAD)
NEEDS_TAG=$(git describe --contains $GIT_COMMIT 2>/dev/null)

# tag and push only if no tag exists for the current commit
if [[ -z $NEEDS_TAG ]]; then
    echo "Tagged with $NEW_TAG"
    git tag $NEW_TAG
    # Set git user for the commit
    git config user.name "GitHub Actions"
    git config user.email "actions@github.com"
    # Set remote URL with GH_PAT for authentication
    git remote set-url origin https://${GH_PAT}@github.com/${GITHUB_REPOSITORY}.git
    git push origin $NEW_TAG
else
    echo "Already a tag on this commit"
fi

# set output for GitHub Actions
echo ::set-output name=new_tag::$NEW_TAG

exit 0
