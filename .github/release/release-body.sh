#!/usr/bin/env bash
#
# Prints the GitHub Release body for a tag to stdout.
#
# Body = <changelog> + the standard "Which download do I want?" section.
#
# Changelog source, in order of preference:
#   1. .github/release/notes/<tag>.md   (hand-written bullets - preferred)
#   2. git log <prev_tag>..<tag>        (auto-generated fallback)
#
# The download section is generated from the tag, the previous tag, and the
# Unity version read from ProjectSettings/ProjectVersion.txt.
#
# Usage: release-body.sh <tag> [prev_tag]

set -euo pipefail

TAG="${1:?usage: release-body.sh <tag> [prev_tag]}"
PREV_TAG="${2:-}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NOTES_FILE="$SCRIPT_DIR/notes/${TAG}.md"

if [ -z "$PREV_TAG" ]; then
	PREV_TAG="$(git describe --tags --abbrev=0 "${TAG}^" 2>/dev/null || true)"
fi

UNITY_VERSION="$(grep '^m_EditorVersion:' ProjectSettings/ProjectVersion.txt | head -1 | awk '{print $2}')"

# --- changelog ---
if [ -f "$NOTES_FILE" ]; then
	cat "$NOTES_FILE"
elif [ -n "$PREV_TAG" ]; then
	echo "## Changes since ${PREV_TAG}"
	echo
	git log --no-merges --pretty='- %s' "${PREV_TAG}..${TAG}"
else
	echo "## ${TAG}"
fi

# --- standard download guide ---
cat <<EOF

## Which download do I want?

**${REPO_NAME:-GT_CustomMapExample}_${TAG}.zip** (full project)
The complete Unity project, including all example content and the official maps. Best for new map makers or anyone starting fresh. Unzip it, then in Unity Hub click Open/Add and select the folder containing \`Assets\`, \`Packages\`, and \`ProjectSettings\`. Requires Unity ${UNITY_VERSION} with Android build support.

**${REPO_NAME:-GT_CustomMapExample}_${TAG}_Minimal.zip** (lightweight starter)
A stripped-down project: the SDK, the placeholder prefabs and the assets they depend on, shaders, and a single \`MinimalExample\` scene, nothing else. Best if you want a small, clean project to build your own map in from scratch, importing only your own assets. Opens the same way as the full project.
EOF

if [ -n "$PREV_TAG" ]; then
	cat <<EOF

**${REPO_NAME:-GT_CustomMapExample}_${TAG}_UpdatesOnly.zip** (upgrade an existing ${PREV_TAG} project)
Everything you need to bring a ${PREV_TAG} project up to ${TAG}. To upgrade: close Unity, unzip, and copy the contents of the unzipped folder into your project's root folder (the one containing \`Assets\`), merging and overwriting when asked. Reopen the project and let Unity import.
EOF
fi
