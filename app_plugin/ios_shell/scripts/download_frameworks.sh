#!/bin/bash
#
# Downloads ios_system XCFrameworks from GitHub releases.
#
# Usage: ./download_frameworks.sh
#
# This script downloads pre-compiled XCFrameworks for iOS shell functionality
# from the ios_system project (a-shell).
#
# License: BSD-3-Clause
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRAMEWORKS_DIR="$SCRIPT_DIR/../ios/Frameworks"

# ios_system release version
IOS_SYSTEM_VERSION="3.0.4"
GITHUB_BASE="https://github.com/holzschu/ios_system/releases/download/v${IOS_SYSTEM_VERSION}"

# Frameworks to download
# Note: curl_ios excluded because it requires libssh2 which is not available
FRAMEWORKS=(
    "ios_system"
    "shell"
    "files"
    "text"
    "tar"
    "awk"
)

TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

echo "Downloading ios_system XCFrameworks..."
echo "Version: $IOS_SYSTEM_VERSION"
echo "Destination: $FRAMEWORKS_DIR"
echo ""

# Create frameworks directory
mkdir -p "$FRAMEWORKS_DIR"

for framework in "${FRAMEWORKS[@]}"; do
    zip_file="${framework}.xcframework.zip"
    download_url="${GITHUB_BASE}/${zip_file}"

    echo "Downloading ${framework}..."

    # Download the zip file
    if curl -sL -o "$TEMP_DIR/$zip_file" "$download_url"; then
        # Extract to frameworks directory
        unzip -q -o "$TEMP_DIR/$zip_file" -d "$FRAMEWORKS_DIR"
        echo "  ✓ Installed ${framework}.xcframework"
    else
        echo "  ✗ Failed to download ${framework}"
    fi
done

echo ""
echo "Done! Frameworks installed to: $FRAMEWORKS_DIR"
echo ""
echo "Installed frameworks:"
ls -la "$FRAMEWORKS_DIR"/*.xcframework 2>/dev/null | awk '{print "  " $NF}' || echo "  (none)"

echo ""
echo "Framework sizes:"
for framework in "${FRAMEWORKS[@]}"; do
    if [ -d "$FRAMEWORKS_DIR/${framework}.xcframework" ]; then
        size=$(du -sh "$FRAMEWORKS_DIR/${framework}.xcframework" | cut -f1)
        echo "  ${framework}: $size"
    fi
done

echo ""
echo "License: BSD-3-Clause (ios_system project)"
echo "Source: https://github.com/holzschu/ios_system"
echo ""
echo "To track these frameworks with Git LFS, run:"
echo "  git lfs track 'app_plugin/ios_shell/ios/Frameworks/*.xcframework/**/*'"
