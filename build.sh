#!/bin/sh
#  build.sh
#  keymanengine-spm
#
#  Created by David Moore on 3/26/25.
#
KEYMAN_ENGINE_TAG="minv0.1.1"
KEYMAN_ENGINE_CHECKOUT="origin/stable-17.0"

KEYMAN_ENGINE_REPO="https://github.com/davidmoore1/keyman"
WORK_DIR=".tmp/keyman"

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
for f in $(ls "$XCDEST_DIR")
do
    if [[ $f == *.zip ]]; then
        gh release upload $KEYMAN_ENGINE_TAG "$XCDEST_DIR/$f"
    fi
done

gh release edit $KEYMAN_ENGINE_TAG --draft=false

echo "All done!"
