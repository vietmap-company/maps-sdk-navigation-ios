#!/usr/bin/env bash

set -e
set -o pipefail
set -u

if [ -z `which jazzy` ]; then
    echo "Installing jazzy…"
    gem install jazzy
    if [ -z `which jazzy` ]; then
        echo "Unable to install jazzy. See https://github.com/mapbox/mapbox-gl-native/blob/master/platform/ios/INSTALL.md"
        exit 1
    fi
fi


OUTPUT=${OUTPUT:-documentation}

BRANCH=$( git describe --tags --match=v*.*.* --abbrev=0 )
SHORT_VERSION=$( echo ${BRANCH} | sed 's/^v//' )
RELEASE_VERSION=$( echo ${SHORT_VERSION} | sed -e 's/-.*//' )
MINOR_VERSION=$( echo ${SHORT_VERSION} | grep -Eo '^\d+\.\d+' )

DEFAULT_THEME="docs/theme"
THEME=${JAZZY_THEME:-$DEFAULT_THEME}

BASE_URL="https://www.mapbox.com/mapbox-navigation-ios"

# Link to directions documentation
DIRECTIONS_VERSION=$(grep 'VietMapDirections.swift' Cartfile.resolved | grep -oE '"v.+?"' | grep -oE '[^"v]+')
DIRECTIONS_SYMBOLS="ComponentRepresentable|Directions|DirectionsOptions|DirectionsResult|Intersection|Lane|Match|MatchOptions|RoadClasses|Route|RouteLeg|RouteOptions|RouteStep|SpokenInstruction|Tracepoint|VisualInstruction|VisualInstructionBanner|VisualInstructionComponent|Waypoint"

rm -rf ${OUTPUT}
mkdir -p ${OUTPUT}

cp -r docs/img "${OUTPUT}"

rm -rf /tmp/mbnavigation
mkdir -p /tmp/mbnavigation/
README=/tmp/mbnavigation/README.md
cp docs/cover.md "${README}"
perl -pi -e "s/\\$\\{MINOR_VERSION\\}/${MINOR_VERSION}/" "${README}"
# http://stackoverflow.com/a/4858011/4585461
echo "## Changes in version ${RELEASE_VERSION}" >> "${README}"
sed -n -e '/^## /{' -e ':a' -e 'n' -e '/^## /q' -e 'p' -e 'ba' -e '}' CHANGELOG.md >> "${README}"

# Blow away any platform-based availability attributes, since everything is
# compatible enough to be documented.
# https://github.com/mapbox/mapbox-navigation-ios/issues/1682
find Mapbox{Core,}Navigation/ -name *.swift -exec \
    perl -pi -e 's/\@available\s*\(\s*iOS \d+.\d,.*?\)//' {} \;

jazzy \
    --podspec VietMapNavigation-Documentation.podspec \
    --config docs/jazzy.yml \
    --sdk iphonesimulator \
    --module-version ${SHORT_VERSION} \
    --github-file-prefix "https://github.com/mapbox/mapbox-navigation-ios/tree/${BRANCH}" \
    --readme ${README} \
    --documentation="docs/guides/*.md" \
    --root-url "${BASE_URL}/navigation/${RELEASE_VERSION}/" \
    --theme ${THEME} \
    --output ${OUTPUT}

REPLACE_REGEXP='s/VietMapNavigation\s+(Docs|Reference)/Mapbox Navigation SDK for iOS $1/, '
REPLACE_REGEXP+='s/BRANDLESS_DOCSET_TITLE/Navigation SDK for iOS $1/, '
REPLACE_REGEXP+="s/<span class=\"kt\">(${DIRECTIONS_SYMBOLS})<\/span>/<span class=\"kt\"><a href=\"${BASE_URL//\//\\/}\/directions\/${DIRECTIONS_VERSION}\/Classes\/\$1.html\">\$1<\/a><\/span>/, "

find ${OUTPUT} -name *.html -exec \
    perl -pi -e "$REPLACE_REGEXP" {} \;


echo $SHORT_VERSION > $OUTPUT/latest_version
