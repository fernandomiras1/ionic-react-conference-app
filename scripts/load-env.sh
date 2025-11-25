#!/bin/bash
# Script to load environment variables and run fastlane commands

# Load environment variables from .env.local if it exists
if [ -f .env.local ]; then
    export $(cat .env.local | sed 's/#.*//g' | xargs)
fi

# Load environment variables from .env if it exists
if [ -f .env ]; then
    export $(cat .env | sed 's/#.*//g' | xargs)
fi

# Execute the command passed as arguments
exec "$@"
