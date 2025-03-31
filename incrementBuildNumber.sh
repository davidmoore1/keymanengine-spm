#!/bin/bash
#  incrementBuildNumber.sh
#  keymanengine-spm
#
#  Created by David Moore on 3/31/25.
#

# File containing the version
FILE="build.sh"

# Extract the current version using awk (more reliable than sed for macOS)
CURRENT_VERSION=$(awk -F '"' '/KEYMAN_ENGINE_TAG=/ {print $2}' "$FILE" | sed 's/v//')

if [[ -z "$CURRENT_VERSION" ]]; then
  echo "Version number not found in $FILE"
  exit 1
fi

# Parse major, minor, and patch versions
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"

# Increment the patch version
PATCH=$((PATCH + 1))

# Construct the new version
NEW_VERSION="v$MAJOR.$MINOR.$PATCH"

# Replace the old version with the new version in the file
sed -i '' "s/KEYMAN_ENGINE_TAG=\"v$CURRENT_VERSION\"/KEYMAN_ENGINE_TAG=\"$NEW_VERSION\"/" "$FILE"

echo "Version bumped to $NEW_VERSION"
