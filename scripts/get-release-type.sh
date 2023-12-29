#!/usr/bin/env bash

set -e

LAST_TAG=$(git describe --abbrev=0 --tags 2>/dev/null || echo "")
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
