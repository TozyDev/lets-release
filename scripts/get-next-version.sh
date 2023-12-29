#!/usr/bin/env bash

set -e

function glob_version_format() {
  local VERSION_FORMAT=$1
  VERSION_FORMAT=${VERSION_FORMAT/major/[0-9]*}
  VERSION_FORMAT=${VERSION_FORMAT/minor/[0-9]*}
  VERSION_FORMAT=${VERSION_FORMAT/patch/[0-9]*}
  VERSION_FORMAT=${VERSION_FORMAT/micro/[0-9]*}
  VERSION_FORMAT=${VERSION_FORMAT/YYYY/[0-9]*}
  VERSION_FORMAT=${VERSION_FORMAT/YY/[0-9]*}
  VERSION_FORMAT=${VERSION_FORMAT/0Y/[0-9]*}
  VERSION_FORMAT=${VERSION_FORMAT/MM/[0-9]*}
  VERSION_FORMAT=${VERSION_FORMAT/0M/[0-9]*}
  VERSION_FORMAT=${VERSION_FORMAT/WW/[0-9]*}
  VERSION_FORMAT=${VERSION_FORMAT/0W/[0-9]*}
  VERSION_FORMAT=${VERSION_FORMAT/DD/[0-9]*}
  VERSION_FORMAT=${VERSION_FORMAT/0D/[0-9]*}
  echo "$VERSION_FORMAT"
}

function replace_sem_ver_placeholders() {
  local VERSION=$1
  VERSION=${VERSION/major/$2}
  VERSION=${VERSION/minor/$3}
  VERSION=${VERSION/patch/$4}
  VERSION=${VERSION/micro/$4}
  echo "$VERSION"
}

function replace_cal_ver_placeholders() {
  local VERSION=$1
  VERSION=${VERSION/YYYY/$(date +%Y)}
  VERSION=${VERSION/YY/$(date +%y)}
  VERSION=${VERSION/0Y/$(date +%0y)}
  VERSION=${VERSION/MM/$(date +%m)}
  VERSION=${VERSION/0M/$(date +%0m)}
  VERSION=${VERSION/WW/$(date +%V)}
  VERSION=${VERSION/0W/$(date +%0V)}
  VERSION=${VERSION/DD/$(date +%d)}
  VERSION=${VERSION/0D/$(date +%0d)}
  echo "$VERSION"
}

RELEASE_TYPE=$1

VERSION_FORMAT=$2
VERSION_FORMAT=${VERSION_FORMAT/MAJOR/major}
VERSION_FORMAT=${VERSION_FORMAT/MINOR/minor}
VERSION_FORMAT=${VERSION_FORMAT/PATCH/patch}
VERSION_FORMAT=${VERSION_FORMAT/MICRO/micro}
if [ -z "$VERSION_FORMAT" ]; then
  VERSION_FORMAT="major.minor.patch"
fi

NEXT_VERSION=$VERSION_FORMAT

LATEST_VERSION=$(git describe --abbrev=0 --tags --match="v$(glob_version_format $VERSION_FORMAT)" 2>/dev/null || echo "")
LATEST_VERSION=${LATEST_VERSION#"v"}

if [ -z "$LATEST_VERSION" ]; then
  LATEST_VERSION=$VERSION_FORMAT
  LATEST_VERSION=$(replace_sem_ver_placeholders "$LATEST_VERSION" 1 0 0)
  NEXT_VERSION=$LATEST_VERSION
  RELEASE_TYPE="none"
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

NEXT_VERSION=$(replace_sem_ver_placeholders "$NEXT_VERSION" "$MAJOR" "$MINOR" "$PATCH")
NEXT_VERSION=$(replace_cal_ver_placeholders "$NEXT_VERSION")

echo "$NEXT_VERSION"
