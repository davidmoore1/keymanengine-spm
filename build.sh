#!/bin/bash
#  build.sh
#  keymanengine-spm
#
#  Created by David Moore on 3/26/25.
#
set -e

KEYMAN_ENGINE_TAG="v0.1.3"
KEYMAN_ENGINE_CHECKOUT="origin/stable-17.0"
KEYMAN_ENGINE_REPO="https://github.com/davidmoore1/keyman"
NODE_VERSION="18.17.0"
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
sed -i '' -e "s/let release =.*/let release = \"$KEYMAN_ENGINE_TAG\"/" Package.swift

XCFRAMEWORK_DIR="$WORK_DIR/ios/build/Build/Products/Debug"
XCDEST_DIR="$WORK_DIR/ios/build/Build/Products/SPM"
XCCARTHAGE_DIR="$WORK_DIR/ios/Carthage/Build"

echo "Copying Frameworks to SPM Directory..."
mkdir -p "$XCDEST_DIR"
rm -rf "$XCDEST_DIR"/*
cp -R "$XCCARTHAGE_DIR"/*.xcframework "$XCDEST_DIR"
cp -R "$XCFRAMEWORK_DIR"/KeymanEngine.xcframework "$XCDEST_DIR"

rm -rf $XCDEST_DIR/*.zip

for f in $(ls "$XCDEST_DIR")
do
    echo "Adding $f to package list..."
    PACAKGE="$XCDEST_DIR/$f"
    ditto -c -k --sequesterRsrc --keepParent $PACAKGE "$PACAKGE.zip"
    PACKAGE_NAME=$(basename "$f" .xcframework)
    PACKAGE_SUM=$(sha256sum "$PACAKGE.zip" | awk '{ print $1 }')
    PACKAGE_STRING="$PACKAGE_STRING\"$PACKAGE_NAME\": \"$PACKAGE_SUM\", "
done

PACKAGE_STRING=$(basename "$PACKAGE_STRING" ", ")
sed -i '' -e "s/let frameworks =.*/let frameworks = [$PACKAGE_STRING]/" Package.swift

echo "Configuring Git..."
git config --global user.email "github-actions[bot]@users.noreply.github.com"
git config --global user.name "github-actions[bot]"
git remote set-url origin https://x-access-token:$GH_TOKEN@github.com/davidmoore1/keymanengine-spm.git

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
for f in $(ls "$XCDEST_DIR")
do
    if [[ $f == *.zip ]]; then
        gh release upload $KEYMAN_ENGINE_TAG "$XCDEST_DIR/$f"
    fi
done

gh release edit $KEYMAN_ENGINE_TAG --draft=false

echo "All done!"

