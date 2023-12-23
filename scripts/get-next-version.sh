#!/usr/bin/env bash

RELEASE_TYPE=$1

VERSION_FORMAT=$2
VERSION_FORMAT=${VERSION_FORMAT/MAJOR/major}
VERSION_FORMAT=${VERSION_FORMAT/MINOR/minor}
VERSION_FORMAT=${VERSION_FORMAT/PATCH/patch}
VERSION_FORMAT=${VERSION_FORMAT/MICRO/micro}
if [ -z "$VERSION_FORMAT" ]; then
    VERSION_FORMAT="major.minor.patch"
fi

LATEST_VERSION=$(git describe --abbrev=0 --tags 2>/dev/null || echo "")
LATEST_VERSION=${LATEST_VERSION#"v"}
if [ -z "$LATEST_VERSION" ]; then
    LATEST_VERSION="1.0.0"
fi

MAJOR_INDEX=-1
MINOR_INDEX=-1
PATCH_INDEX=-1

IFS='.|_|-' read -ra VERSION_PARTS <<< "$VERSION_FORMAT"
for i in "${!VERSION_PARTS[@]}"; do
    case "${VERSION_PARTS[$i]}" in
        "major") MAJOR_INDEX=$((i + 1)) ;;
        "minor") MINOR_INDEX=$((i + 1)) ;;
        "patch"|"micro") PATCH_INDEX=$((i + 1)) ;;
    esac
done

if [ "$MAJOR_INDEX" -ne -1 ]; then
    MAJOR=$(echo "$LATEST_VERSION" | awk -F '[.|_|-]' '{print $'"$MAJOR_INDEX"'}')
fi

if [ "$MINOR_INDEX" -ne -1 ]; then
    MINOR=$(echo "$LATEST_VERSION" | awk -F '[.|_|-]' '{print $'"$MINOR_INDEX"'}')
fi

if [ "$PATCH_INDEX" -ne -1 ]; then
    PATCH=$(echo "$LATEST_VERSION" | awk -F '[.|_|-]' '{print $'"$PATCH_INDEX"'}')
fi

case "$RELEASE_TYPE" in
    "major")
      MAJOR=$((MAJOR + 1))
      MINOR=0
      PATCH=0
      ;;
    "minor")
      MINOR=$((MINOR + 1))
      PATCH=0
      ;;
    "patch"|"micro")
      PATCH=$((PATCH + 1))
      ;;
esac

NEXT_VERSION="$VERSION_FORMAT"

# Replace SemVer placeholders
NEXT_VERSION=${NEXT_VERSION/major/$MAJOR}
NEXT_VERSION=${NEXT_VERSION/minor/$MINOR}
NEXT_VERSION=${NEXT_VERSION/patch/$PATCH}
NEXT_VERSION=${NEXT_VERSION/micro/$PATCH}

# Replace CalVer placeholders
NEXT_VERSION=${NEXT_VERSION/YYYY/$(date +%Y)}
NEXT_VERSION=${NEXT_VERSION/YY/$(date +%y)}
NEXT_VERSION=${NEXT_VERSION/0Y/$(date +%0y)}
NEXT_VERSION=${NEXT_VERSION/MM/$(date +%m)}
NEXT_VERSION=${NEXT_VERSION/0M/$(date +%0m)}
NEXT_VERSION=${NEXT_VERSION/WW/$(date +%V)}
NEXT_VERSION=${NEXT_VERSION/0W/$(date +%0V)}
NEXT_VERSION=${NEXT_VERSION/DD/$(date +%d)}
NEXT_VERSION=${NEXT_VERSION/0D/$(date +%0d)}

echo "$NEXT_VERSION"
