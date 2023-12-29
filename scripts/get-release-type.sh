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

VERSION_FORMAT=$1
VERSION_FORMAT=${VERSION_FORMAT/MAJOR/major}
VERSION_FORMAT=${VERSION_FORMAT/MINOR/minor}
VERSION_FORMAT=${VERSION_FORMAT/PATCH/patch}
VERSION_FORMAT=${VERSION_FORMAT/MICRO/micro}
if [ -z "$VERSION_FORMAT" ]; then
  VERSION_FORMAT="major.minor.patch"
fi

LAST_TAG=$(git describe --abbrev=0 --tags --match="v$(glob_version_format $VERSION_FORMAT)" 2>/dev/null || echo "")
COMMIT_HISTORY_MESSAGES=$(git log --format="%s (%h)" "$LAST_TAG${LAST_TAG:+..}HEAD" 2>/dev/null)

RELEASE_TYPE=0

IFS=$'\n'
for RAW in ${COMMIT_HISTORY_MESSAGES}; do
  COMMIT_TYPE=$(echo "${RAW}" | cut -d':' -f1 | xargs)
  IS_BREAKING_CHANGE=$([[ "${COMMIT_TYPE}" == "!"* ]] && echo true || echo false)

  if [[ "${IS_BREAKING_CHANGE}" == true ]]; then
    RELEASE_TYPE=1
    break
  fi

  COMMIT_TYPE=$(echo "${COMMIT_TYPE}" | cut -d'(' -f1 | xargs)
  if [[ "${COMMIT_TYPE}" == "feat" ]]; then
    RELEASE_TYPE=2
  fi

  if [[ "${COMMIT_TYPE}" == "fix" ]]; then
    RELEASE_TYPE=3
  fi
done

case $RELEASE_TYPE in
  0) echo "none" ;;
  1) echo "major" ;;
  2) echo "minor" ;;
  3) echo "patch" ;;
esac
