#!/usr/bin/env bash

set -e

VERSION=$1
PART_TYPE=$2
VERSION_FORMAT=$3
if [ -z "$VERSION_FORMAT" ]; then
    VERSION_FORMAT="major.minor.patch"
fi

PART_INDEX=-1

IFS='.|_|-' read -ra VERSION_PARTS <<< "$VERSION_FORMAT"
for i in "${!VERSION_PARTS[@]}"; do
  if [ "${VERSION_PARTS[$i]}" == "$PART_TYPE" ]; then
    PART_INDEX=$((i + 1))
    break
  fi
done

if [ "$PART_INDEX" -ne -1 ]; then
  PART=$(echo "$VERSION" | awk -F '[.|_|-]' '{print $'"$PART_INDEX"'}')
fi

echo "$PART"
