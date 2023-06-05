#!/bin/bash

set -eo pipefail

# Set output directory
OUTPUT_DIR="./build/vietmap"

# Clean up the output directory if it exists
if [ -d "$OUTPUT_DIR" ]; then
  rm -rf "$OUTPUT_DIR"
fi

# Build XCFramework for iOS devices (arm64, armv7)
xcodebuild archive \
  -scheme "MapboxNavigation" \
  -archivePath "$OUTPUT_DIR/MapboxNavigation-iOS" \
  -sdk "iphoneos" \
  -configuration Release \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  archive \
  SKIP_INSTALL=NO | xcpretty

# Build XCFramework for iOS simulator (x86_64, arm64)
xcodebuild archive \
  -scheme "MapboxNavigation" \
  -archivePath "$OUTPUT_DIR/MapboxNavigation-iOS-Simulator" \
  -sdk "iphonesimulator" \
  -configuration Release \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  archive \
  SKIP_INSTALL=NO | xcpretty

# Create a universal XCFramework
xcodebuild -create-xcframework \
  -framework "$OUTPUT_DIR/MapboxNavigation-iOS.xcarchive/Products/Library/Frameworks/MapboxNavigation.framework" \
  -framework "$OUTPUT_DIR/MapboxNavigation-iOS-Simulator.xcarchive/Products/Library/Frameworks/MapboxNavigation.framework" \
  -output "$OUTPUT_DIR/MapboxNavigation.xcframework"

# Clean up the intermediate build artifacts
rm -rf "$OUTPUT_DIR/MapboxNavigation-iOS.xcarchive"
rm -rf "$OUTPUT_DIR/MapboxNavigation-iOS-Simulator.xcarchive"

echo "Distribution XCFramework is created at: $OUTPUT_DIR/MapboxNavigation.xcframework"
