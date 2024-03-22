#!/bin/bash

# Get folder of this script
SCRIPTSOURCE="${BASH_SOURCE[0]}"
FLWSOURCE="$(readlink -f "$SCRIPTSOURCE")"
SCRIPTDIR="$(dirname "$FLWSOURCE")"

# Change to assumed project root folder.
cd "$SCRIPTDIR"/../

# Load users fixture.
echo "Loading users fixture into database."
rails db:fixtures:load FIXTURES=users
echo "Done."
