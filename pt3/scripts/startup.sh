#!/bin/bash

# Get folder of this script
SCRIPTSOURCE="${BASH_SOURCE[0]}"
FLWSOURCE="$(readlink -f "$SCRIPTSOURCE")"
SCRIPTDIR="$(dirname "$FLWSOURCE")"

# Source environment variables in root of source folder if RAILS_ENV is not already set.
if [ -z $RAILS_ENV ]; then
    source $SCRIPTDIR/../.env
fi

# Print rails environment.
echo "Current rails environment: $RAILS_ENV."

# Remove pid if it exists (from a previous startup)
[ -f tmp/pids/server.pid ] && rm tmp/pids/server.pid

# Update dependencies
bundle update

# Run migrations automatically in dev
[ "$RAILS_ENV" == "development" ] && rails db:migrate

# Precompile assets (for production)
# Set config.assets.compile = true temporarily to enable asset pipeline in production.
rails assets:precompile

# Add fixtures for development env
[ "$RAILS_ENV" == "development" ] && /app/scripts/loadtest.sh

# Run server
[ "${NO_PUMA_SERVER}X" == "yesX" ] && while true; do sleep 100; done
rails server
