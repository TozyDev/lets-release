#!/usr/bin/env bash

set -e
declare -A TYPE_HEADERS=(
  ["breaking"]="💥 Breaking Changes"
  ["feat"]="✨ Features"
  ["fix"]="🐞 Bug Fixed"
  ["perf"]="⚡️ Performance Improvements"
  ["revert"]="⏪ Reverts"
  ["docs"]="📚 Documentation"
  ["style"]="💄 Styles"
  ["chore"]="🔧 Miscellaneous Changes"
  ["refactor"]="♻️ Code Refactoring"
  ["test"]="✅ Tests"
  ["build"]="🧱 Build System"
  ["ci"]="👷 CI/CD Pipeline"
  ["other"]="Other Changes"
)
declare -A RELEASE_NOTES=(
  ["breaking"]=""
  ["feat"]=""
  ["fix"]=""
  ["perf"]=""
  ["revert"]=""
  ["docs"]=""
  ["style"]=""
  ["chore"]=""
  ["refactor"]=""
  ["test"]=""
  ["build"]=""
  ["ci"]=""
  ["other"]=""
)
declare -a EXCLUDE_COMMIT_MESSAGES=(
  "chore(*): init *"
  "chore(*): release *"
)

LAST_TAG=$(git describe --abbrev=0 --tags 2>/dev/null || echo "")
COMMIT_HISTORY_MESSAGES=$(git log --format="%s (%h)" "${LAST_TAG:+..}HEAD" 2>/dev/null)

function process_history_message() {
  local RAW=$1

  for EXCLUDE_COMMIT_MESSAGE in "${EXCLUDE_COMMIT_MESSAGES[@]}"; do
    # shellcheck disable=SC2053
    if [[ "${RAW}" == $EXCLUDE_COMMIT_MESSAGE ]]; then
      return
    fi
  done

  local COMMIT_TYPE
  COMMIT_TYPE=$(echo "${RAW}" | cut -d':' -f1 | xargs)

  local IS_BREAKING_CHANGE
  IS_BREAKING_CHANGE=$([[ "${COMMIT_TYPE}" == "!"* ]] && echo true || echo false)

  local COMMIT_SCOPE
  COMMIT_SCOPE=$(echo "${COMMIT_TYPE}" | cut -d'(' -f2 | cut -d')' -f1 | xargs)

  local COMMIT_DESCRIPTION
  COMMIT_DESCRIPTION=$(echo "${RAW}" | cut -d':' -f2- | xargs)

  local COMMIT_TYPE
  COMMIT_TYPE=$(echo "${COMMIT_TYPE}" | cut -d'(' -f1 | xargs)

  if [[ "${IS_BREAKING_CHANGE}" == true ]]; then
      COMMIT_TYPE="breaking"
  fi

  if [[ -z "${COMMIT_TYPE}" ]]; then
    COMMIT_TYPE="other"
  fi

  local COMMIT_DESCRIPTION_WITH_SCOPE="${COMMIT_DESCRIPTION}"
  if [[ -n "${COMMIT_SCOPE}" ]]; then
    COMMIT_DESCRIPTION_WITH_SCOPE="**${COMMIT_SCOPE}:** ${COMMIT_DESCRIPTION}"
  fi
  RELEASE_NOTES["${COMMIT_TYPE}"]="${RELEASE_NOTES["${COMMIT_TYPE}"]}"$'\n'"- ${COMMIT_DESCRIPTION_WITH_SCOPE}"
}

IFS=$'\n'
for RAW in ${COMMIT_HISTORY_MESSAGES}; do
  process_history_message "${RAW}"
done

RELEASE_NOTES_BODY="## Release Notes"
for TYPE in "${!TYPE_HEADERS[@]}"; do
  if [[ -n "${RELEASE_NOTES["${TYPE}"]}" ]]; then
    RELEASE_NOTES_BODY="${RELEASE_NOTES_BODY}"$'\n'"### ${TYPE_HEADERS["${TYPE}"]}"$'\n'"${RELEASE_NOTES["${TYPE}"]}"$'\n'
  fi
done

RELEASE_NOTES_FILE=$1
if [[ -n "${RELEASE_NOTES_FILE}" ]]; then
  echo "${RELEASE_NOTES_BODY}" > "${RELEASE_NOTES_FILE}"
else
  echo "${RELEASE_NOTES_BODY}"
fi
