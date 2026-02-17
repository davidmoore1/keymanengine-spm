#!/bin/bash
#  build.sh
#  keymanengine-spm
#
#  Created by David Moore on 3/26/25.
#
set -e

KEYMAN_ENGINE_TAG="v0.18.4"
KEYMAN_ENGINE_CHECKOUT="origin/stable-18.0-dm"

KEYMAN_ENGINE_REPO="https://github.com/davidmoore1/keyman"
WORK_DIR=".tmp/keyman"

mkdir -p ~/.nvm
export NVM_DIR="$HOME/.nvm"

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
rm -rf "${XCDEST_DIR:?}"/*
cp -R "$XCCARTHAGE_DIR"/*.xcframework "$XCDEST_DIR" || true
cp -R "$XCFRAMEWORK_DIR"/KeymanEngine.xcframework "$XCDEST_DIR" || true

rm -rf "$XCDEST_DIR"/*.zip

# Remember repository root so we can call the helper script from inside the dest dir
REPO_ROOT=$(pwd)

for path in "$XCDEST_DIR"/*; do
    [ -e "$path" ] || continue
    f=$(basename "$path")
    echo "Adding $f to package list..."
    PACKAGE_NAME=$(basename "$f" .xcframework)
    # Create a zip of the xcframework inside the XCDEST_DIR so paths and output locations are predictable
    (cd "$XCDEST_DIR" && ditto -c -k --sequesterRsrc --keepParent "$f" "$PACKAGE_NAME.zip")

    # Run the unsign helper from inside the XCDEST_DIR so the unsigned zip is produced there
    if [[ -x "$REPO_ROOT/scripts/unsign_xcframework.sh" ]]; then
        (cd "$XCDEST_DIR" && "$REPO_ROOT/scripts/unsign_xcframework.sh" "$PACKAGE_NAME.zip")
        UNSIGNED="$XCDEST_DIR/$PACKAGE_NAME.unsigned.zip"
        if [[ -f "$UNSIGNED" ]]; then
            # Replace the original zip with the unsigned one (keep the same target name)
            mv -f "$UNSIGNED" "$XCDEST_DIR/$PACKAGE_NAME.zip"
        fi
    fi

    # Compute checksum of the (now unsigned) zip; prefer shasum on macOS if available
    if command -v shasum >/dev/null 2>&1; then
        PACKAGE_SUM=$(shasum -a 256 "$XCDEST_DIR/$PACKAGE_NAME.zip" | awk '{print $1}')
    else
        PACKAGE_SUM=$(sha256sum "$XCDEST_DIR/$PACKAGE_NAME.zip" | awk '{print $1}')
    fi

    PACKAGE_STRING="$PACKAGE_STRING\"$PACKAGE_NAME\": \"$PACKAGE_SUM\", "

done

PACKAGE_STRING=$(basename "$PACKAGE_STRING" ", ")
sed -i '' -e "s/let frameworks =.*/let frameworks = [$PACKAGE_STRING]/" Package.swift

echo "Committing Changes..."
git add -u
git commit -m "Creating release for $KEYMAN_ENGINE_TAG"

echo "Creating Tag..."
git tag $KEYMAN_ENGINE_TAG
git push
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

echo "All done!"
