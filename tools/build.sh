#!/bin/bash
# Build the Playdate package, bumping buildNumber first.
#
# Usage:  tools/build.sh [--run]
#         --run  also open the .pdx in the Simulator
#
# Only buildNumber is touched. `version` (0.9.X) stays a judgment call: it marks a feature
# or a player-visible fix, not "a build happened", so automating it would make it meaningless.
#
# Point a Nova task at this script to get a bump on every build (see docs in BUILD.md).

set -euo pipefail

cd "$(dirname "$0")/.."

SOURCE_DIR="source"
PDX_NAME="DinoPirates from inner space Brocolation.pdx"
PDXINFO="$SOURCE_DIR/pdxinfo"

if [[ ! -f "$PDXINFO" ]]; then
    echo "error: $PDXINFO not found (run from anywhere inside the repo)" >&2
    exit 1
fi

# --- bump buildNumber ------------------------------------------------------
# source/pdxinfo is the only authoritative copy; the *.pdx/pdxinfo files are build output.
current=$(grep -E '^buildNumber=' "$PDXINFO" | cut -d= -f2 | tr -d '[:space:]')

if [[ ! "$current" =~ ^[0-9]+$ ]]; then
    echo "error: could not read buildNumber from $PDXINFO (got '$current')" >&2
    exit 1
fi

next=$((current + 1))

# Write via a temp file so an interrupted run can't leave pdxinfo truncated.
tmp=$(mktemp)
sed "s/^buildNumber=.*/buildNumber=$next/" "$PDXINFO" > "$tmp"
mv "$tmp" "$PDXINFO"

version=$(grep -E '^version=' "$PDXINFO" | cut -d= -f2 | tr -d '[:space:]')
echo "build $current -> $next  (version $version)"

# --- compile ---------------------------------------------------------------
# No -k/--skip-unknown: it would also drop assets/launcher/launchImages/animation.txt
# (real launcher content) and the Noble/Panels LICENSE files, which MIT requires be
# distributed. Docs are kept out of the package by living in DOCS/ at the repo root,
# outside source/, rather than by filtering them here.
if ! pdc "$SOURCE_DIR" "$PDX_NAME"; then
    echo "build failed -- rolling buildNumber back to $current" >&2
    tmp=$(mktemp)
    sed "s/^buildNumber=.*/buildNumber=$current/" "$PDXINFO" > "$tmp"
    mv "$tmp" "$PDXINFO"
    exit 1
fi

if [[ "${1:-}" == "--run" ]]; then
    open "$PDX_NAME"
fi
