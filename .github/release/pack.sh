#!/usr/bin/env bash
#
# Builds the three release zips that every GT_CustomMapExample release ships:
#
#   <name>_<tag>.zip              Full project   - every tracked file (git archive of the tag)
#   <name>_<tag>_Minimal.zip      Lightweight    - only the paths in minimal-files.txt
#   <name>_<tag>_UpdatesOnly.zip  Upgrade delta  - files changed since the previous tag
#
# Runs on git + zip only - no Unity, no DLL build (the DLLs are committed). Safe to run
# locally from Git Bash as well as in CI. Run it from the repo root with the checkout
# sitting on the tag you are releasing.
#
# Usage: pack.sh <tag> [prev_tag] [out_dir]
#   tag       release tag, e.g. v6.4 (must exist as a git tag)
#   prev_tag  previous release tag for the UpdatesOnly delta (auto-detected if omitted)
#   out_dir   output directory for the zips (default: dist)

set -euo pipefail

TAG="${1:?usage: pack.sh <tag> [prev_tag] [out_dir]}"
PREV_TAG="${2:-}"
OUT_DIR="${3:-dist}"

REPO_NAME="GT_CustomMapExample"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFEST="$SCRIPT_DIR/minimal-files.txt"

# Resolve to an absolute output dir so we can cd around while zipping.
mkdir -p "$OUT_DIR"
OUT_DIR="$(cd "$OUT_DIR" && pwd)"

if ! git rev-parse "$TAG" >/dev/null 2>&1; then
	echo "ERROR: git tag '$TAG' does not exist." >&2
	exit 1
fi

if [ -z "$PREV_TAG" ]; then
	PREV_TAG="$(git describe --tags --abbrev=0 "${TAG}^" 2>/dev/null || true)"
fi

echo "Tag:       $TAG"
echo "Prev tag:  ${PREV_TAG:-<none> (UpdatesOnly will be skipped)}"
echo "Out dir:   $OUT_DIR"
echo

# ---------------------------------------------------------------------------
# 1. FULL - the entire tracked project at the tag.
# ---------------------------------------------------------------------------
FULL_ZIP="$OUT_DIR/${REPO_NAME}_${TAG}.zip"
echo "[1/3] Full project  -> $(basename "$FULL_ZIP")"
git archive --format=zip -9 --prefix="${REPO_NAME}_${TAG}/" -o "$FULL_ZIP" "$TAG"

# ---------------------------------------------------------------------------
# 2. MINIMAL - only the curated dependency closure in minimal-files.txt.
#    (That list is a Unity-computed asset closure; regenerate it with the
#    "A7/Regenerate Minimal Release Manifest" editor tool when minimal
#    content changes - see .github/release/README.md.)
# ---------------------------------------------------------------------------
MIN_ZIP="$OUT_DIR/${REPO_NAME}_${TAG}_Minimal.zip"
echo "[2/3] Minimal       -> $(basename "$MIN_ZIP")"
if [ ! -f "$MANIFEST" ]; then
	echo "ERROR: minimal manifest not found at $MANIFEST" >&2
	exit 1
fi

MIN_STAGE="$(mktemp -d)"
MIN_ROOT="$MIN_STAGE/${REPO_NAME}_${TAG}_Minimal"
missing=0
while IFS= read -r f || [ -n "$f" ]; do
	# skip blanks / comments
	case "$f" in
		''|'#'*) continue ;;
	esac
	# read the file as it exists at the tag, not the current working tree
	if git cat-file -e "${TAG}:${f}" 2>/dev/null; then
		mkdir -p "$MIN_ROOT/$(dirname "$f")"
		git show "${TAG}:${f}" > "$MIN_ROOT/$f"
	else
		echo "  WARN: manifest path missing at $TAG (skipped): $f" >&2
		missing=$((missing + 1))
	fi
done < "$MANIFEST"
if [ "$missing" -gt 0 ]; then
	echo "  NOTE: $missing manifest path(s) skipped - the manifest may be stale." >&2
fi
( cd "$MIN_STAGE" && zip -rq -9 "$MIN_ZIP" "${REPO_NAME}_${TAG}_Minimal" )
rm -rf "$MIN_STAGE"

# ---------------------------------------------------------------------------
# 3. UPDATES-ONLY - files changed since the previous tag (excluding deletions).
# ---------------------------------------------------------------------------
UPD_ZIP="$OUT_DIR/${REPO_NAME}_${TAG}_UpdatesOnly.zip"
echo "[3/3] UpdatesOnly   -> $(basename "$UPD_ZIP")"
if [ -z "$PREV_TAG" ]; then
	echo "  SKIP: no previous tag, nothing to diff against (first release?)."
else
	UPD_STAGE="$(mktemp -d)"
	UPD_ROOT="$UPD_STAGE/${REPO_NAME}_${TAG}_UpdatesOnly"
	count=0
	while IFS= read -r f || [ -n "$f" ]; do
		[ -z "$f" ] && continue
		mkdir -p "$UPD_ROOT/$(dirname "$f")"
		git show "${TAG}:${f}" > "$UPD_ROOT/$f"
		count=$((count + 1))
	done < <(git diff --name-only --diff-filter=d "$PREV_TAG" "$TAG")

	if [ "$count" -eq 0 ]; then
		echo "  SKIP: no changed files between $PREV_TAG and $TAG."
		rm -rf "$UPD_STAGE"
	else
		echo "  $count changed file(s) since $PREV_TAG."
		( cd "$UPD_STAGE" && zip -rq -9 "$UPD_ZIP" "${REPO_NAME}_${TAG}_UpdatesOnly" )
		rm -rf "$UPD_STAGE"
	fi
fi

echo
echo "Done. Artifacts in $OUT_DIR:"
ls -la "$OUT_DIR"/*.zip
