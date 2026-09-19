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
PDXINFO="$SOURCE_DIR/pdxinfo"

if [[ ! -f "$PDXINFO" ]]; then
    echo "error: $PDXINFO not found (run from anywhere inside the repo)" >&2
    exit 1
fi

# Output name is DERIVED from pdxinfo's `name`, matching what Nova's Playdate extension does
# when Product Name is "Automatic". Hardcoding a different name here is how this project ended
# up with two .pdx folders -- Nova building one and the terminal building the other, so
# whichever you ran was whichever you last built by hand.
PDX_NAME="$(grep -E '^name=' "$PDXINFO" | cut -d= -f2-).pdx"

if [[ "$PDX_NAME" == ".pdx" ]]; then
    echo "error: could not read 'name' from $PDXINFO" >&2
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
