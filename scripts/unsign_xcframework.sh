#!/usr/bin/env bash
# Unsign an .xcframework (zip) by removing embedded code signatures from contained .frameworks
# Usage: ./unsign_xcframework.sh /path/to/SomeFramework.xcframework.zip
# Outputs a new file named SomeFramework.xcframework.unsigned.zip and prints a sha256 checksum ready for use in Package.swift
set -euo pipefail

if [[ "$#" -ne 1 ]]; then
  echo "Usage: $0 /path/to/Framework.xcframework.zip"
  exit 2
fi

INPUT_ZIP="$1"
if [[ ! -f "$INPUT_ZIP" ]]; then
  echo "File not found: $INPUT_ZIP"
  exit 2
fi

WORKDIR=$(mktemp -d)
cleanup() {
  rm -rf "$WORKDIR"
}
trap cleanup EXIT

echo "Working in $WORKDIR"

# Unzip into workdir
unzip -q "$INPUT_ZIP" -d "$WORKDIR"

# Find all .framework directories inside the xcframework and remove code signature resources
# We will remove _CodeSignature, CodeResources, and any CodeSignature files in Mach-O fat/thin bundles
find "$WORKDIR" -type d -name "*.framework" | while read -r FRAMEWORK; do
  echo "Processing framework: $FRAMEWORK"
  # Remove CodeSignature directory
  if [[ -d "$FRAMEWORK/_CodeSignature" ]]; then
    echo "  Removing _CodeSignature"
    rm -rf "$FRAMEWORK/_CodeSignature"
  fi
  # Remove CodeResources if present (older signature formats)
  if [[ -f "$FRAMEWORK/CodeResources" ]]; then
    echo "  Removing CodeResources"
    rm -f "$FRAMEWORK/CodeResources"
  fi

  # For nested binary files, run codesign --remove-signature if available (macOS 10.15+ has it)
  BINARY_NAME=$(basename "$FRAMEWORK" .framework)
  BINARY_PATH="$FRAMEWORK/$BINARY_NAME"
  if [[ -f "$BINARY_PATH" ]]; then
    if command -v codesign >/dev/null 2>&1; then
      echo "  Attempting to remove signature from binary: $BINARY_PATH"
      # Some versions of codesign support --remove-signature
      if codesign --remove-signature "$BINARY_PATH" 2>/dev/null; then
        echo "    Removed signature using codesign --remove-signature"
      else
        # Fallback: try to strip __TEXT,__entitlements or use lipo to extract slices and strip signatures by removing CodeSignature directories is often enough
        echo "    codesign --remove-signature not supported or failed; ensured resource signature files were removed"
      fi
    fi
  fi

  # Also remove any embedded .dSYM or other code signature artifacts
  find "$FRAMEWORK" -name "CodeSignature" -o -name "*_CodeSignature" -o -name "CodeResources" -print0 | xargs -0 rm -rf 2>/dev/null || true

done

# Rezip the xcframework contents
BASE_NAME=$(basename "$INPUT_ZIP")
OUT_ZIP="$WORKDIR/${BASE_NAME%.zip}.unsigned.zip"
(cd "$WORKDIR" && zip -r -q "$OUT_ZIP" .)

# Move output to current directory
DEST="$(pwd)/${BASE_NAME%.zip}.unsigned.zip"
mv "$OUT_ZIP" "$DEST"

echo "Created unsigned xcframework: $DEST"

# Print sha256 checksum for Package.swift
if command -v shasum >/dev/null 2>&1; then
  SHA=$(shasum -a 256 "$DEST" | awk '{print $1}')
  echo "sha256: $SHA"
fi

exit 0
