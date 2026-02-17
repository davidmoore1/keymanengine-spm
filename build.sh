#!/bin/bash
#  build.sh
#  keymanengine-spm
#
#  Created by David Moore on 3/26/25.
#
set -e

# Flags: --no-release: do everything but skip committing/pushing and GitHub release/upload
#        --dry-run: produce unsigned zips and checksums but do NOT modify Package.swift or perform any git/gh actions
NO_RELEASE=0
DRY_RUN=0
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --no-release)
      NO_RELEASE=1; shift;;
    --dry-run)
      DRY_RUN=1; shift;;
    --help)
      echo "Usage: $0 [--no-release] [--dry-run]"; exit 0;;
    *) echo "Unknown arg: $1"; echo "Usage: $0 [--no-release] [--dry-run]"; exit 2;;
  esac
done

KEYMAN_ENGINE_TAG="v0.18.1"
KEYMAN_ENGINE_CHECKOUT="origin/stable-18.0-dm"
KEYMAN_ENGINE_REPO="https://github.com/davidmoore1/keyman"
NODE_VERSION="20.16.0"
WORK_DIR=".tmp/keyman"

mkdir -p ~/.nvm
export NVM_DIR="$HOME/.nvm"

# Check if Homebrew-installed NVM exists, otherwise fallback to manually installed NVM
if [ -s "$(brew --prefix)/opt/nvm/nvm.sh" ]; then
    . "$(brew --prefix)/opt/nvm/nvm.sh"
elif [ -s "$NVM_DIR/nvm.sh" ]; then
    . "$NVM_DIR/nvm.sh"
else
    echo "Error: nvm not found" >&2
    exit 1
fi

# Load bash completion (optional)
[ -s "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm" ] && \
    . "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm"

nvm install $NODE_VERSION
nvm use $NODE_VERSION
node -v  # Verify installation

if [[ ! -d $WORK_DIR ]]; then
  echo "Cloning keyman repository..."
  mkdir .tmp/ || true
  cd .tmp/
  git clone $KEYMAN_ENGINE_REPO
  cd ../
fi

echo "Checking out $KEYMAN_ENGINE_CHECKOUT..."
cd $WORK_DIR
git fetch
git fetch --tags
git checkout $KEYMAN_ENGINE_CHECKOUT

echo "Building for iOS..."
cd ios/
./build.sh build:engine --debug

echo "Updating package file..."
cd ../../..
pwd
ls
PACKAGE_STRING=""
if [[ $DRY_RUN -eq 0 ]]; then
  sed -i '' -e "s/let release =.*/let release = \"$KEYMAN_ENGINE_TAG\"/" Package.swift
else
  echo "Dry-run: skipping Package.swift release update"
fi

XCFRAMEWORK_DIR="$WORK_DIR/ios/build/Build/Products/Debug"
XCDEST_DIR="$WORK_DIR/ios/build/Build/Products/SPM"
XCCARTHAGE_DIR="$WORK_DIR/ios/Carthage/Build"

echo "Copying Frameworks to SPM Directory..."
mkdir -p "$XCDEST_DIR"
rm -rf "${XCDEST_DIR:?}"/*
cp -R "$XCCARTHAGE_DIR"/*.xcframework "$XCDEST_DIR" || true
cp -R "$XCFRAMEWORK_DIR"/KeymanEngine.xcframework "$XCDEST_DIR" || true

rm -rf "$XCDEST_DIR"/*.zip

# Remember repository root so we can call the helper script from inside the dest dir
REPO_ROOT=$(pwd)

# Iterate safely over entries in the XCDEST_DIR
for path in "$XCDEST_DIR"/*; do
    [ -e "$path" ] || continue
    f=$(basename "$path")
    echo "Adding $f to package list..."
    PACAKGE="$XCDEST_DIR/$f"
    # Create zip using ditto; ensure arguments are quoted
    ZIP_FILENAME="${f}.zip"
    ditto -c -k --sequesterRsrc --keepParent "$PACAKGE" "$XCDEST_DIR/$ZIP_FILENAME"
    PACKAGE_NAME=$(basename "$f" .xcframework)

    # Run unsign helper to remove embedded code signatures from the zipped xcframework
    if [[ -x "$REPO_ROOT/scripts/unsign_xcframework.sh" ]]; then
        (cd "$XCDEST_DIR" && "$REPO_ROOT/scripts/unsign_xcframework.sh" "$ZIP_FILENAME")
        UNSIGNED="$XCDEST_DIR/${f}.unsigned.zip"
        if [[ -f "$UNSIGNED" ]]; then
            mv -f "$UNSIGNED" "$XCDEST_DIR/$ZIP_FILENAME"
        fi
    fi

    # Compute checksum using shasum on macOS if available
    if command -v shasum >/dev/null 2>&1; then
        PACKAGE_SUM=$(shasum -a 256 "$XCDEST_DIR/$ZIP_FILENAME" | awk '{ print $1 }')
    else
        PACKAGE_SUM=$(sha256sum "$XCDEST_DIR/$ZIP_FILENAME" | awk '{ print $1 }')
    fi
    PACKAGE_STRING="$PACKAGE_STRING\"$PACKAGE_NAME\": \"$PACKAGE_SUM\", "

done

PACKAGE_STRING=$(basename "$PACKAGE_STRING" ", ")
if [[ $DRY_RUN -eq 0 ]]; then
  sed -i '' -e "s/let frameworks =.*/let frameworks = [$PACKAGE_STRING]/" Package.swift
else
  echo "Dry-run: skipping Package.swift frameworks update"
  echo "Computed package checksums: $PACKAGE_STRING"
fi

if [[ $NO_RELEASE -eq 0 && $DRY_RUN -eq 0 ]]; then
  echo "Configuring Git..."
  git config --global user.email "github-actions[bot]@users.noreply.github.com"
  git config --global user.name "github-actions[bot]"
  # Quote GH_TOKEN to avoid word-splitting
  git remote set-url origin "https://x-access-token:${GH_TOKEN}@github.com/davidmoore1/keymanengine-spm.git"

  echo "Committing Changes..."
  git add -u
  git commit -m "Creating release for $KEYMAN_ENGINE_TAG"

  echo "Creating Tag..."
  git tag $KEYMAN_ENGINE_TAG
  git push origin main  # Ensure you're pushing to the correct branch
  git push origin --tags

  echo "Creating Release..."
  gh release create -p -d $KEYMAN_ENGINE_TAG --title "KeymanEngine SPM $KEYMAN_ENGINE_TAG" --generate-notes --verify-tag

  echo "Uploading Binaries..."
  for path in "$XCDEST_DIR"/*; do
      [ -e "$path" ] || continue
      f=$(basename "$path")
      if [[ $f == *.zip ]]; then
          gh release upload $KEYMAN_ENGINE_TAG "$XCDEST_DIR/$f"
      fi
  done

  gh release edit $KEYMAN_ENGINE_TAG --draft=false
else
  echo "Skipping git/gh release/upload steps (NO_RELEASE=$NO_RELEASE, DRY_RUN=$DRY_RUN)"
fi

echo "All done!"
